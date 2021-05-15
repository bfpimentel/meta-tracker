import Head from "next/head";
import { track } from "@/data/MetaTracker";
import { InferGetStaticPropsType } from "next";

const Trackings = ({
  trackings,
}: InferGetStaticPropsType<typeof getServerSideProps>) => (
  <div className="flex flex-col items-center justify-center min-h-screen py-4 px-2">
    <Head>
      <title>Meta Tracker</title>
      <link rel="icon" href="/favicon.ico" />
    </Head>

    <main className="max-w-1/3">
      <p className="text-4xl text-center font-semibold">Meta Tracker</p>
      {trackings.map((tracking) => (
        <div key={tracking.code}>
          <p className="text-xl mt-4 font-bold">{tracking.code}</p>
          {tracking.steps.map((step, index) => (
            <p key={index}>{step.status}</p>
          ))}
        </div>
      ))}
    </main>
  </div>
);

export const getServerSideProps = async (context: {
  params: { codes: string };
}) => {
  const splitCodes = context.params.codes.split(",");
  const trackings = await track(...splitCodes);

  console.log(trackings);

  return {
    props: {
      trackings: trackings,
    },
  };
};

export default Trackings;
