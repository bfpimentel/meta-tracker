import type { NextApiRequest, NextApiResponse } from "next";
import cheerio from "cheerio";
import iconv from "iconv-lite";
import fetch from "node-fetch";
import FormData from "form-data";

interface TrackingRequestBody {
  codes: string[];
}

interface Tracking {
  code: string;
  events: Event[];
  isDelivered?: boolean;
  postedAt?: Date;
  updatedAt?: Date;
}

interface Event {
  description: string;
  country?: string;
  state?: string;
  city?: string;
  trackedAt: Date;
}

export default async (
  request: NextApiRequest,
  response: NextApiResponse<Tracking[]>
) => {
  const requestBody: TrackingRequestBody = request.body;
  response.status(200).json(await track(requestBody.codes));
};

const track = (codes: string[]) => Promise.all(codes.map(requestTracking));

const isCodeInputValid = (code: string) =>
  /^[A-Z]{2}[0-9]{9}[A-Z]{2}$/.test(code);

async function requestTracking(code: string): Promise<Tracking> {
  try {
    const form = new FormData();
    form.append("objetos", code);

    const options = {
      method: "POST",
      body: form,
    };

    const response = fetch(
      "https://www2.correios.com.br/sistemas/rastreamento/resultado_semcontent.cfm",
      options
    );

    return response.then(async (response) => {
      //   if (!response.ok) {
      //     throw new Error("Erro ao rastrear objeto.");
      //   }

      const decodedResponse = await response
        .arrayBuffer()
        .then((arrayBuffer) =>
          iconv.decode(Buffer.from(arrayBuffer), "iso-8859-1").toString()
        );

      const events = getEvents(decodedResponse);

      const [firstEvent, lastEvent] = [events[0], events[events.length - 1]];

      return {
        code: code,
        postedAt: firstEvent.trackedAt,
        updatedAt: lastEvent.trackedAt,
        isDelivered: lastEvent.description.includes("Objeto entregue"),
        events: events,
      };
    });
  } catch (error) {
    console.error(error);
  }
}

function getEvents(html: string) {
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

  const events = data.map((line) => {
    const trackedAt = new Date(
      line[0][0].split("/").reverse().join("-").concat(` ${line[0][1]} -3`)
    );

    const places = line[0][2].split("/").map((place) => place.trim());

    let country = places[1] ? null : places[0];

    const [city, state] = country ? [null, null] : [places[0], places[1]];

    if (!country) {
      country = "BRASIL";
    }

    let description = line[1][0];

    if (line[1][1]) {
      const subdescription = line[1].slice(1).join(" ");

      description =
        description.replace(" - por favor aguarde", " ") + subdescription;
    }

    return {
      description: description,
      trackedAt: trackedAt,
      city: city,
      state: state,
      country: country,
    };
  });

  return events.reverse();
}
