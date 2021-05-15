import Head from "next/head";
import { track } from "@/data/MetaTracker";
import { InferGetStaticPropsType } from "next";

const Home = () => (
  <div className="flex flex-col items-center justify-center min-h-screen py-4 px-2">
    <Head>
      <title>Meta Tracker</title>
      <link rel="icon" href="/favicon.ico" />
    </Head>

    <main className="w-1/3">
      <p className="text-4xl text-center font-semibold">Meta Tracker</p>
    </main>
  </div>
);

export default Home;
