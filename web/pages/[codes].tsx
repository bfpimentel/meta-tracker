import Head from "next/head";
import {
  GetServerSideProps,
  GetServerSidePropsContext,
  InferGetServerSidePropsType,
} from "next";
import { track, Tracking } from "@/data/repository";
import ThemeSwitcher from "@/components/ThemeSwitcher";
import moment from "moment";

export default function Trackings({
  trackings,
}: InferGetServerSidePropsType<typeof getServerSideProps>) {
  return (
    <div className="flex flex-col items-center justify-center">
      <Head>
        <title>Meta Tracker</title>
        <link rel="icon" href="/favicon.ico" />
      </Head>

      <main className="flex flex-col max-w-3xl py-4 px-2">
        <div className="flex flex-row justify-between">
          <p className="text-4xl text-center font-semibold">Meta Tracker</p>
          <ThemeSwitcher />
        </div>
        {trackings.map((tracking) => (
          <div key={tracking.code}>
            <div className="mt-4 border-t border-black border-opacity-10 dark:border-white dark:border-opacity-10"></div>
            <p className="text-xl mt-4 font-bold">{tracking.code}</p>
            <EventsList tracking={tracking} />
          </div>
        ))}
      </main>
    </div>
  );
}

function EventsList({ tracking }: { tracking: Tracking }) {
  if (tracking.isTracked) {
    return (
      <>
        {tracking.events.map((event, index) => (
          <div key={index} className="mt-2">
            <p className="text-gray-500 dark:text-gray-400">
              {moment(event.trackedAt).format("DD/MM/yyyy [às] HH:mm")}
            </p>
            <p>{event.description}</p>
          </div>
        ))}
      </>
    );
  }

  if (tracking.errorMessage) {
    return (
      <p className="mt-2">
        Não foi possível exibir informações para o código informado, motivo:{" "}
        {tracking.errorMessage}
      </p>
    );
  }

  return (
    <p className="mt-2">
      Não foi possível exibir informações para o código informado.
      <br />
      Se o objeto foi postado recentemente, por favor tente novamente mais
      tarde.
      <br />
      Adicionalmente, verifique se informou o código correto.
    </p>
  );
}

export async function getServerSideProps(context: GetServerSidePropsContext) {
  const codes = context.params.codes as string;
  const splitCodes = codes.split(",");
  const trackings: Tracking[] = await track(splitCodes);

  return {
    props: {
      trackings: trackings,
    },
  };
}
