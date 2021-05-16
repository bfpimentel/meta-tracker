import React, { useEffect, useState } from "react";
import Head from "next/head";
import { useRouter } from "next/router";
import ThemeSwitcher from "@/components/ThemeSwitcher";

export default function Home() {
  const router = useRouter();
  const [input, setInput] = useState("");

  const submit = () => {
    if (!input) {
      alert("Necessário inserir pelo menos um código!");
      return;
    }

    const isCodeNotValid = (code: string) =>
      !/^[A-Z]{2}[0-9]{9}[A-Z]{2}$/.test(code);

    const codes = input.trim().replace(" ", "");
    const splitCodes = codes.split(",");
    const invalidCodes = splitCodes.filter(isCodeNotValid);

    if (invalidCodes.length > 0) {
      alert(`Existem códigos inválidos: ${invalidCodes.join()}`);
      return;
    }

    router.push(`/${codes}`);
  };

  return (
    <div className="flex flex-col items-center justify-between min-h-screen">
      <Head>
        <title>Meta Tracker</title>
        <link rel="icon" href="/favicon.ico" />
      </Head>

      <main className="flex flex-col max-w-3xl py-4 px-2 w-full">
        <div className="flex flex-row justify-between">
          <p className="text-4xl text-center font-semibold">Meta Tracker</p>
          <ThemeSwitcher />
        </div>
        <div className="mt-4 border-t border-black border-opacity-10 dark:border-white dark:border-opacity-10"></div>
        <p className="text-xl mt-4">
          Meta Tracker é uma aplicação open-source desenvolvida para facilitar o
          rastreamento de encomendas dos Correios do Brasil.
          <br />
          Todos os dados são de posse do usuário, então, a aplicação não guarda
          informações na nuvem.
          <br />
          Esse é um projeto em progresso e quase não possui validações, por
          enquanto. Então, ao utilizar, esteja ciente que códigos válidos são o
          ideal.
        </p>
        <div className="mt-4 border-t border-black border-opacity-10 dark:border-white dark:border-opacity-10"></div>
        <p className="text-xl mt-4">
          Insira abaixo códigos a serem rastreados, separados por vírgula:
        </p>
        <textarea
          onChange={(event) => setInput(event.target.value)}
          placeholder="EX: AB111111111BR, CD222222222BR"
          className="
            p-2 mt-4 bg-transparent border rounded-md outline-none
            border-black border-opacity-10 focus:border-black focus:border-opacity-80
            dark:border-white dark:border-opacity-10 dark:focus:border-white dark:focus:border-opacity-80 
          "
        ></textarea>
        <button
          onClick={() => submit()}
          disabled={!input}
          className="self-end mt-4 p-2 rounded-md font-bold opacity-100 disabled:opacity-50 bg-black text-white dark:bg-white dark:text-black"
        >
          Rastrear
        </button>
      </main>

      <footer
        className="flex flox-row justify-between max-w-3xl w-full border-t py-4 px-2
        border-black border-opacity-10 dark:border-white dark:border-opacity-10"
      ></footer>
    </div>
  );
}
