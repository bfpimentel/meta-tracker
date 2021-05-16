import React, { useEffect, useState } from "react";
import Head from "next/head";
import { InferGetStaticPropsType } from "next";
import { useTheme } from "next-themes";
import { track } from "@/data/repository";
import moment from "moment";

export default function Trackings({
  trackings,
}: InferGetStaticPropsType<typeof getServerSideProps>) {
  const { theme, setTheme } = useTheme();
  const [isMounted, setIsMounted] = useState(false);

  useEffect(() => {
    setIsMounted(true);
  });

  const switchTheme = () => {
    if (isMounted) {
      setTheme(theme === "light" ? "dark" : "light");
    }
  };

  return (
    <div className="flex flex-col items-center justify-center">
      <Head>
        <title>Meta Tracker</title>
        <link rel="icon" href="/favicon.ico" />
      </Head>

      <main className="flex flex-col max-w-3xl py-4 px-2">
        <div className="flex flex-row justify-between">
          <p className="text-4xl text-center font-semibold">Meta Tracker</p>
          <button
            onClick={switchTheme}
            className="p-2 rounded-md font-bold bg-black text-white dark:bg-white dark:text-black"
          >
            Give me {theme === "light" ? "Darkness" : "Light"}
          </button>
        </div>
        {trackings.map((tracking) => (
          <div key={tracking.code}>
            <div className="mt-4 border-t border-black border-opacity-10 dark:border-white dark:border-opacity-10"></div>
            <p className="text-xl mt-4 font-bold">{tracking.code}</p>
            {tracking.events.map((event, index) => (
              <div key={index} className="mt-2">
                <p className="text-gray-500 dark:text-gray-400">
                  {moment(event.trackedAt).format("DD/MM/yyyy [às] HH:mm")}
                </p>
                <p>{event.description}</p>
              </div>
            ))}
          </div>
        ))}
      </main>
    </div>
  );
}

export const getServerSideProps = async (context: {
  params: { codes: string };
}) => {
  const splitCodes = context.params.codes.split(",");
  const trackings = await track(splitCodes);

  return {
    props: {
      trackings: trackings,
    },
  };
};
