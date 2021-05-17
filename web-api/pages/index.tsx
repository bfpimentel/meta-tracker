import React, { useState } from "react";
import { useRouter } from "next/router";

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

    const codesInput = input.trim().replace(/[^A-Za-z0-9,]/g, "");
    const splitCodes = codesInput.split(",");
    const invalidCodes = splitCodes.filter(isCodeNotValid);

    if (invalidCodes.length > 0) {
      setInput(codesInput);
      alert(`Existem códigos inválidos: ${invalidCodes.join(", ")}`);
      return;
    }

    router.push(`/${codesInput}`);
  };

  return (
    <>
      <div className="mt-4 border-t border-black border-opacity-10 dark:border-white dark:border-opacity-10"></div>
      <p className="text-xl mt-4">
        Meta Tracker é uma aplicação open-source desenvolvida para explorar
        tecnologias e facilitar o rastreamento de encomendas dos Correios do
        Brasil.
        <br />
        Todos os dados são de posse do usuário, então, a aplicação não guarda
        informações na nuvem.
        <br />
        Esse é um projeto em progresso.
      </p>
      <div className="mt-4 border-t border-black border-opacity-10 dark:border-white dark:border-opacity-10"></div>
      <p className="text-xl mt-4">
        Insira abaixo códigos a serem rastreados, separados por vírgula:
      </p>
      <textarea
        onChange={(event) => setInput(event.target.value)}
        value={input}
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
    </>
  );
}
