import fetch from "node-fetch";

export interface Tracking {
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

export const track = (codes: string[]) => requestTracking(codes);

async function requestTracking(codes: string[]): Promise<Tracking[]> {
  const options = {
    method: "POST",
    body: JSON.stringify({ codes: codes }),
    headers: {
      "Content-Type": "application/json",
    },
  };

  const response = fetch(`${process.env.SERVER_BASE_URL}/trackings`, options);

  return response.then(async (response) => {
    const trackings = (await response.json()) as Tracking[];
    return trackings;
  });
}
