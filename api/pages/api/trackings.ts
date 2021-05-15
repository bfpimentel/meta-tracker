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
  // isDelivered?: boolean;
  // postedAt?: Date;
  // updatedAt?: Date;
}

interface Event {
  description: string;
  // country?: string;
  // state?: string;
  // city?: string;
  // trackedAt: Date;
  // observation: string;
  // trackedAt: string;
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

      const [firstEvent, lastEvent] = [events[events.length - 1], events[0]];

      return {
        code: code,
        events: events.map((event) => ({
          description: event.description,
        })),
      };
    });
  } catch (error) {
    console.error(error);
  }
}

function getEvents(html: string) {
  const $ = cheerio.load(html);
  const columns = $(".listEvent").find("tbody").find("tr").toArray();
  const unparsedEvents = columns.map((column) => {
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

  // const steps = lines.toArray().map((line) => {
  //   console.log(`LINE: ${line}`);

  //   const lineData = document(line)
  //     .find("td")
  //     .toArray()
  //     .map((column) =>
  //       document(column)
  //         .text()
  //         .replace(/[\n\r\t]/g, "")
  //         .trim()
  //     )
  //     .filter((data) => !!data)
  //     .map((data) => data.split(/\s\s+/g));

  //   console.log(`LINEDATA: ${lineData}`);

  //   return {
  //     // locale: lineData[0][2].toLowerCase(),
  //     status: lineData[1][0].toLowerCase(),
  //     // observation: lineData[1][1] ? lineData[1][1].toLowerCase() : null,
  //     // trackedAt: new Date(
  //     //   lineData[0][0]
  //     //     .split("/")
  //     //     .reverse()
  //     //     .join("-")
  //     //     .concat(` ${lineData[0][1]} -3`)
  //     // ),
  //   };
  // });

  const events = unparsedEvents.reverse().map((event) => {
    let description = event[1][0];

    if (event[1][1]) {
      description =
        description.replace(" - por favor aguarde", " ") + event[1][1];
    }

    return {
      description: description,
    };
  });

  //   {
  // const local = eventLog[0][2].split("/");
  // const event = {
  //   data: eventLog[0][0],
  //   dataHora: `${eventLog[0][0]} ${eventLog[0][1]}`,
  //   status: eventLog[1][0],
  //   cidade: local[0].trim(),
  //   uf: local[1].trim(),
  // };
  // if (eventLog[1][1]) {
  //   const destino = eventLog[1][1].split(" ");
  //   event.destino = {
  //     cidade: destino[destino.length - 3],
  //     uf: destino[destino.length - 1],
  //   };
  // }
  //   });

  return events;
}

// function parseHtmlToData(html: string): Step[] {
//   const document = cheerio.load(html);
//   const lines = document(".listEvent").find("tr");

//   // const steps2 = lines.toArray().flatMap((line) => {
//   //   document(line).find(".sroLbEvent").find("strong").text;
//   // });

// const steps = lines.toArray().map((line) => {
//   console.log(`LINE: ${line}`);

//   const lineData = document(line)
//     .find("td")
//     .toArray()
//     .map((column) =>
//       document(column)
//         .text()
//         .replace(/[\n\r\t]/g, "")
//         .trim()
//     )
//     .filter((data) => !!data)
//     .map((data) => data.split(/\s\s+/g));

//   console.log(`LINEDATA: ${lineData}`);

//   return {
//     // locale: lineData[0][2].toLowerCase(),
//     status: lineData[1][0].toLowerCase(),
//     // observation: lineData[1][1] ? lineData[1][1].toLowerCase() : null,
//     // trackedAt: new Date(
//     //   lineData[0][0]
//     //     .split("/")
//     //     .reverse()
//     //     .join("-")
//     //     .concat(` ${lineData[0][1]} -3`)
//     // ),
//   };
// });

//   console.log(steps.map(({ status }) => status).join());

//   if (!steps.length) return null;

//   const [firstTrack, lastTrack] = [steps[steps.length - 1], steps[0]];

//   return steps.reverse();

//   // return {
//   //   steps: steps.reverse(),
//   //   //   isDelivered: lastTrack.status.includes("objeto entregue"),
//   //   //   postedAt: firstTrack.trackedAt,
//   //   //   updatedAt: lastTrack.trackedAt,
//   // };
// }
