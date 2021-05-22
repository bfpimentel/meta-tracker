import React from "react";
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

type StoredTracking = {
  code: string;
  name: string;
};

type HomeState = {
  name: string;
  code: string;
  error: string;
  isButtonDisabled: boolean;
  trackings: TrackingViewData[];
};

class Home extends React.Component<{}, HomeState> {
  storedTrackings: StoredTracking[] = [];
  isMounted = false;

  constructor(props: {}) {
    super(props);
    this.state = {
      name: "",
      code: "",
      error: "",
      isButtonDisabled: true,
      trackings: []
    };
  }

  fetchTrackings() {
    if (!this.storedTrackings) {
      return;
    }

    async function getTrackings(codes: string[]): Promise<Tracking[]> {
      const trackings: Tracking[] = await track(codes);
      return trackings;
    }

    const codes = this.storedTrackings.map((tracking) => tracking.code);
    const fetchedTrackings = getTrackings(codes);

    fetchedTrackings.then((trackings) => {
      if (this.isMounted)
        this.setState({
          trackings: trackings.map((tracking) => ({
            name: this.storedTrackings.find((storedTracking) => storedTracking.code == tracking.code).name,
            ...tracking
          }))
        });
    });
  }

  componentDidMount() {
    this.isMounted = true;
    this.storedTrackings = JSON.parse(localStorage.getItem("trackings")) || [];
    this.fetchTrackings();
  }

  componentWillUnmount() {
    this.state = { name: "", code: "", error: "", isButtonDisabled: true, trackings: [] };
    this.isMounted = false;
  }

  setCode(code: string) {
    this.setState({ code: code }, () => this.updateState());
  }

  setName(name: string) {
    this.setState({ name: name }, () => this.updateState());
  }

  updateState() {
    const storedTracking = this.storedTrackings.find(
      (storedTracking) => storedTracking.code == this.state.code || storedTracking.name == this.state.name
    );

    const trackingAlreadyExists = !!storedTracking;
    const isCodeNotValid = !/^[A-Z]{2}[0-9]{9}[A-Z]{2}$/.test(this.state.code);
    const isNameNotValid = !this.state.name;

    const getErrorMessage = () => {
      if (isCodeNotValid) return "Insira um código válido.";
      if (trackingAlreadyExists) return "Uma encomenda com esse código ou nome já existe.";
      return "";
    };

    const isButtonDisabled = trackingAlreadyExists || isCodeNotValid || isNameNotValid;

    this.setState({
      error: getErrorMessage(),
      isButtonDisabled: isButtonDisabled
    });
  }

  submitNewTracking() {
    const newTracking = { code: this.state.code, name: this.state.name };

    if (this.storedTrackings) this.storedTrackings.push(newTracking);
    else this.storedTrackings = [newTracking];

    localStorage.setItem("trackings", JSON.stringify(this.storedTrackings));

    this.fetchTrackings();
  }

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
        <div className="grid md:grid-cols-2 sm:grid-cols-1 items-stretch md:space-x-4 sm:space-x-0">
          <input
            onChange={(event) => this.setCode(event.currentTarget.value)}
            placeholder="AB111111111BR"
            className="
              p-2 mt-4 bg-transparent border rounded-md outline-none
              border-black border-opacity-10 focus:border-black focus:border-opacity-80
              dark:border-white dark:border-opacity-10 dark:focus:border-white dark:focus:border-opacity-80 
            "
          ></input>
          <input
            onChange={(event) => this.setName(event.currentTarget.value)}
            placeholder="Bugiganga"
            className="
              p-2 mt-4 bg-transparent border rounded-md outline-none
              border-black border-opacity-10 focus:border-black focus:border-opacity-80
              dark:border-white dark:border-opacity-10 dark:focus:border-white dark:focus:border-opacity-80 
            "
          ></input>
        </div>
        <div className="flex mt-4 items-center justify-items-stretch">
          <ValidationError errorMessage={this.state.error} />
          <button
            onClick={() => this.submitNewTracking()}
            disabled={this.state.isButtonDisabled}
            className="self-end p-2 rounded-md font-bold opacity-100 disabled:opacity-50 bg-black text-white dark:bg-white dark:text-black"
          >
            Rastrear
          </button>
        </div>
        <Trackings trackings={this.state.trackings} />
      </>
    );
  }
}

const Trackings: React.FunctionComponent<{ trackings: TrackingViewData[] }> = ({ trackings }) => {
  if (!trackings) {
    return <></>;
  }

  return (
    <>
      {trackings.map((tracking) => (
        <div key={tracking.code}>
          <div className="mt-4 border-t border-black border-opacity-10 dark:border-white dark:border-opacity-10"></div>
          <div className="flex mt-4">
            <p className="flex-grow text-xl font-bold">{tracking.name}</p>
            <p className="text-xl font-bold">{tracking.code}</p>
          </div>
          <EventsList tracking={tracking} />
        </div>
      ))}
    </>
  );
};

const EventsList: React.FunctionComponent<{ tracking: TrackingViewData }> = ({ tracking }) => {
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

const ValidationError: React.FunctionComponent<{ errorMessage: string }> = ({ errorMessage }) => {
  if (errorMessage) {
    return <p className="flex-grow text-red-500">{errorMessage}</p>;
  }

  return <div className="flex-grow"></div>;
};

export default Home;
