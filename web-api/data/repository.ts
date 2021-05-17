import fetch from "node-fetch";

export interface Tracking {
  code: string;
  events: Event[];
  isTracked: boolean;
  isDelivered: boolean;
  postedAt?: Date;
  updatedAt?: Date;
  errorMessage?: string;
}

export interface Event {
  description: string;
  country?: string;
  state?: string;
  city?: string;
  trackedAt: Date;
}

export const track = (codes: string[]) => requestTracking(codes);

async function requestTracking(codes: string[]): Promise<Tracking[]> {
  const options = {
    method: "GET",
    headers: {
      "Content-Type": "application/json",
    },
  };

  const query = new URLSearchParams({ codes: codes.join(",") });

  const response = fetch(
    `${process.env.SERVER_BASE_URL}/trackings?${query}`,
    options
  );

  return response.then(async (response) => {
    const trackings = (await response.json()) as Tracking[];
    return trackings;
  });
}
