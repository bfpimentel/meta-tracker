import React, { FunctionComponent } from "react";
import ThemeSwitcher from "@/components/ThemeSwitcher";
import Head from "@/components/Head";

const Page: FunctionComponent<{}> = ({ children }) => {
  return (
    <div className="flex flex-col items-center justify-between h-screen">
      <Head />

      <main className="flex flex-col max-w-3xl w-full pt-8 pb-4 px-2">
        <div className="flex flex-row justify-between">
          <p className="text-4xl text-center font-semibold">Meta Tracker</p>
          <ThemeSwitcher />
        </div>
        {children}
      </main>

      <footer className="flex flex-col justify-between pb-8 px-2 max-w-3xl w-full">
        <div className="border-t border-black border-opacity-10 dark:border-white dark:border-opacity-10"></div>
        <a href="https://github.com/bfpimentel/meta-tracker" className="self-center ">
          <button className="mt-4 p-2 rounded-md font-bold bg-black text-white dark:bg-white dark:text-black">
            Contribua com o projeto!
          </button>
        </a>
      </footer>
    </div>
  );
};

export default Page;
