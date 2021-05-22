import type { NextApiRequest, NextApiResponse } from "next";
import cheerio from "cheerio";
import iconv from "iconv-lite";
import fetch from "node-fetch";
import FormData from "form-data";
import createRateLimiter from "@/caching/rate-limiter";

interface TrackingResponseBody {
  code: string;
  isTracked: boolean;
  events: EventResponseBody[];
  errorMessage?: string;
}

class Tracked implements TrackingResponseBody {
  code: string;
  isDelivered: boolean;
  isTracked: boolean;
  postedAt: Date;
  updatedAt: Date;
  events: EventResponseBody[];

  constructor(code: string, events: EventResponseBody[]) {
    this.code = code;
    this.isTracked = true;

    const [firstEvent, lastEvent] = [events[0], events[events.length - 1]];

    this.postedAt = firstEvent.trackedAt;
    this.updatedAt = lastEvent.trackedAt;
    this.isDelivered = lastEvent.description.includes("Objeto entregue");
    this.events = events;
  }
}

class NotTrackedYet implements TrackingResponseBody {
  code: string;
  isTracked: boolean;
  events: EventResponseBody[];

  constructor(code: string) {
    this.code = code;
    this.isTracked = false;
    this.events = [];
  }
}

class TrackingError implements TrackingResponseBody {
  code: string;
  isTracked: boolean;
  events: EventResponseBody[];
  errorMessage: string;

  constructor(code: string, errorMessage: string) {
    this.code = code;
    this.errorMessage = errorMessage;
    this.isTracked = false;
  }
}

interface EventResponseBody {
  description: string;
  country: string;
  state?: string;
  city?: string;
  trackedAt: Date;
}

const limiter = createRateLimiter();

export default async (request: NextApiRequest, response: NextApiResponse) => {
  try {
    await limiter.check(response, 10, "GET_TRACKINGS_CACHE_TOKEN");
  } catch {
    return response.status(429).json({
      code: 429,
      error: "Limite de requisições excedido, tente novamente mais tarde."
    });
  }

  try {
    const query = request.query["codes"];

    if (Array.isArray(query)) {
      return response.status(400).json({
        code: 400,
        error:
          "Sintaxe de requisição inválida, use vírgulas para separar os códigos, ex: trackings?codes=AB111111111BR,CD222222222BR"
      });
    }

    const codes = query.split(",");
    const trackings = await getAllTrackings(codes);
    return response.status(200).json(trackings);
  } catch (error) {
    return response.status(503).json({
      code: 503,
      error: "Serviço indisponível"
    });
  }
};

const getAllTrackings = (codes: string[]): Promise<TrackingResponseBody[]> => Promise.all(codes.map(getTracking));

const getTracking = async (code: string): Promise<TrackingResponseBody> => {
  const isCodeNotValid = (code: string) => !/^[A-Z]{2}[0-9]{9}[A-Z]{2}$/.test(code);

  if (isCodeNotValid(code)) {
    return new TrackingError(code, "Código inválido");
  }

  const form = new FormData();
  form.append("objetos", code);

  const options = {
    method: "POST",
    body: form
  };

  const response = fetch("https://www2.correios.com.br/sistemas/rastreamento/resultado_semcontent.cfm", options);

  return response.then(async (response) => {
    const decodedResponse = await response
      .arrayBuffer()
      .then((arrayBuffer) => iconv.decode(Buffer.from(arrayBuffer), "iso-8859-1").toString());

    const events = getEvents(decodedResponse);

    if (events.length == 0) {
      return new NotTrackedYet(code);
    }

    return new Tracked(code, events);
  });
};

const getEvents = (html: string) => {
  const $ = cheerio.load(html);
  const columns = $(".listEvent").find("tbody").find("tr").toArray();
  const data = columns.map((column) => {
    const data = $(column)
      .find("td")
      .toArray()
      .map((line) =>
        $(line)
          .text()
          .replace(/[\t\n\r]/g, "")
          .trim()
      )
      .map((data) => data.split(/\s\s+/g));
    return data;
  });

  let events = data.flatMap((line) => {
    try {
      let trackedAt = new Date(line[0][0].split("/").reverse().join("-").concat(` ${line[0][1]} -3`));

      const places = line[0][2].split("/").map((place) => place.trim());

      let country = places[1] ? null : places[0];

      const [city, state] = country ? [null, null] : [places[0], places[1]];

      if (!country) {
        country = "BRASIL";
      }

      let description = line[1][0];

      if (line[1][1]) {
        const subdescription = line[1].slice(1).join(" ");
        description = description.replace(" - por favor aguarde", " ");
        description += subdescription;
      }

      return [
        {
          description: description,
          trackedAt: trackedAt,
          city: city?.toUpperCase(),
          state: state?.toUpperCase(),
          country: country.toUpperCase()
        }
      ];
    } catch {
      return [];
    }
  });

  return events.reverse();
};
