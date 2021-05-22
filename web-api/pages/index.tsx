import React, { Component, FunctionComponent, useEffect, useState } from "react";
import { track, Tracking } from "@/data/repository";
import moment from "moment";

type TrackingViewData = {
  name: string;
  code: string;
  events: EventViewData[];
  isTracked: boolean;
  isDelivered: boolean;
  postedAt?: Date;
  updatedAt?: Date;
  errorMessage?: string;
};

type EventViewData = {
  description: string;
  country?: string;
  state?: string;
  city?: string;
  trackedAt: Date;
};

class Home extends Component<{}, { name: string; code: string; trackings: TrackingViewData[] }> {
  isMounted = false;

  constructor(props) {
    super(props);
    this.state = {
      name: "",
      code: "",
      trackings: []
    };
  }

  fetchTrackings() {
    if (!localStorage.getItem("trackings")) {
      return;
    }

    async function getTrackings(codes: string[]): Promise<Tracking[]> {
      const trackings: Tracking[] = await track(codes);
      return trackings;
    }

    const storedTrackings: { name: string; code: string }[] = JSON.parse(localStorage.getItem("trackings"));
    const codes = storedTrackings.map((tracking) => tracking.code);
    const fetchedTrackings = getTrackings(codes);

    fetchedTrackings.then((trackings) => {
      if (this.isMounted)
        this.setState({
          trackings: trackings.map((tracking) => ({
            name: storedTrackings.find((storedTracking) => storedTracking.code == tracking.code).name,
            ...tracking
          }))
        });
    });
  }

  componentDidMount() {
    this.isMounted = true;
    this.fetchTrackings();
  }

  componentWillUnmount() {
    this.state = { name: "", code: "", trackings: [] };
    this.isMounted = false;
  }

  isCodeNotValid = (code: string) => !/^[A-Z]{2}[0-9]{9}[A-Z]{2}$/.test(code);

  submit = () => {
    let storedTrackings: { name: string; code: string }[] = JSON.parse(localStorage.getItem("trackings"));

    const newTracking = { code: this.state.code, name: this.state.name };

    if (storedTrackings) storedTrackings.push(newTracking);
    else storedTrackings = [newTracking];

    localStorage.setItem("trackings", JSON.stringify(storedTrackings));
    this.fetchTrackings();
  };

  render() {
    return (
      <>
        <div className="mt-4 border-t border-black border-opacity-10 dark:border-white dark:border-opacity-10"></div>
        <p className="text-xl mt-4">
          Meta Tracker é uma aplicação open-source desenvolvida para explorar tecnologias e facilitar o rastreamento de
          encomendas dos Correios do Brasil.
          <br />
          Todos os dados são de posse do usuário, então, a aplicação não guarda informações na nuvem.
          <br />
          Esse é um projeto em progresso.
        </p>
        <div className="mt-4 border-t border-black border-opacity-10 dark:border-white dark:border-opacity-10"></div>
        <p className="text-xl mt-4">Insira abaixo um código a ser rastreado, acompanhado de um nome:</p>
        <div className="justify-center md:items-stretch sm:items-center md:flex-row sm:flex-col md:space-x-4 sm:space-y-4">
          <input
            onChange={(event) => this.setState({ code: event.target.value })}
            placeholder="AB111111111BR"
            className="
              p-2 mt-4 bg-transparent border rounded-md 
              border-black border-opacity-10 focus:border-black focus:border-opacity-80
              dark:border-white dark:border-opacity-10 dark:focus:border-white dark:focus:border-opacity-80 
            "
          ></input>
          <input
            onChange={(event) => this.setState({ name: event.target.value })}
            placeholder="Bugiganga"
            className="
              p-2 mt-4 bg-transparent border rounded-md outline-none
              border-black border-opacity-10 focus:border-black focus:border-opacity-80
              dark:border-white dark:border-opacity-10 dark:focus:border-white dark:focus:border-opacity-80 
            "
          ></input>
          <button
            onClick={() => this.submit()}
            disabled={!this.state.name || this.isCodeNotValid(this.state.code)}
            className="md:self-stretch sm:self-end mt-4 p-2 rounded-md font-bold opacity-100 disabled:opacity-50 bg-black text-white dark:bg-white dark:text-black"
          >
            Rastrear
          </button>
        </div>
        <Trackings trackings={this.state.trackings} />
      </>
    );
  }
}

const Trackings: FunctionComponent<{ trackings: TrackingViewData[] }> = ({ trackings }) => {
  if (!trackings) {
    return <></>;
  }

  return (
    <>
      {trackings.map((tracking) => (
        <div key={tracking.code}>
          <div className="mt-4 border-t border-black border-opacity-10 dark:border-white dark:border-opacity-10"></div>
          <p className="text-xl mt-4 font-bold">
            {tracking.code}: {tracking.name}
          </p>
          <EventsList tracking={tracking} />
        </div>
      ))}
    </>
  );
};

const EventsList: FunctionComponent<{ tracking: TrackingViewData }> = ({ tracking }) => {
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
        Não foi possível exibir informações para o código informado. Motivo: {tracking.errorMessage}.
      </p>
    );
  }

  return (
    <p className="mt-2">
      Não foi possível exibir informações para o código informado.
      <br />
      Se o objeto foi postado recentemente, por favor tente novamente mais tarde.
      <br />
      Adicionalmente, verifique se informou o código correto.
    </p>
  );
};

export default Home;
