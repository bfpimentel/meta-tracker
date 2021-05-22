import React from "react";
import { track, Tracking } from "@/data/repository";
import moment from "moment";
import CircleLoading from "react-loading";

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
  isLoading: boolean;
  validationErrorMessage: string;
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
      validationErrorMessage: "",
      isLoading: false,
      isButtonDisabled: true,
      trackings: []
    };
  }

  componentDidMount() {
    this.isMounted = true;
    this.storedTrackings = JSON.parse(localStorage.getItem("trackings")) || [];
    this.fetchTrackings();
  }

  componentWillUnmount() {
    this.state = {
      name: "",
      code: "",
      validationErrorMessage: "",
      isLoading: false,
      isButtonDisabled: true,
      trackings: []
    };
    this.isMounted = false;
  }

  fetchTrackings() {
    if (!this.storedTrackings) {
      return;
    }

    async function getTrackings(codes: string[]): Promise<Tracking[]> {
      const trackings: Tracking[] = await track(codes);
      return trackings;
    }

    this.setState({ isLoading: true }, () => {
      const codes = this.storedTrackings.map((tracking) => tracking.code);
      const fetchedTrackings = getTrackings(codes);

      fetchedTrackings
        .then((trackings) => {
          if (this.isMounted)
            this.setState({
              isLoading: false,
              trackings: trackings.map((tracking) => ({
                name: this.storedTrackings.find((storedTracking) => storedTracking.code == tracking.code).name,
                ...tracking
              }))
            });
        })
        .catch((error) => this.setState({ isLoading: false }));
    });
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
      validationErrorMessage: getErrorMessage(),
      isButtonDisabled: isButtonDisabled
    });
  }

  submitNewTracking() {
    const newTracking = { code: this.state.code, name: this.state.name };

    this.setState({ code: "", name: "" });

    if (this.storedTrackings) this.storedTrackings.push(newTracking);
    else this.storedTrackings = [newTracking];

    localStorage.setItem("trackings", JSON.stringify(this.storedTrackings));

    this.fetchTrackings();
  }

  render() {
    return (
      <>
        {/* <Description /> */}
        <div className="mt-4 border-t border-black border-opacity-10 dark:border-white dark:border-opacity-10"></div>
        <p className="text-xl mt-4">Insira abaixo um código a ser rastreado, acompanhado de um nome:</p>
        <div className="grid md:grid-cols-2 sm:grid-cols-1 items-stretch md:space-x-4 sm:space-x-0">
          <input
            onChange={(event) => this.setCode(event.currentTarget.value)}
            value={this.state.code}
            maxLength={13}
            placeholder="AB111111111BR"
            className="
              p-2 mt-4 bg-transparent border rounded-md outline-none
              border-black border-opacity-10 focus:border-black focus:border-opacity-80
              dark:border-white dark:border-opacity-10 dark:focus:border-white dark:focus:border-opacity-80 
            "
          ></input>
          <input
            onChange={(event) => this.setName(event.currentTarget.value)}
            value={this.state.name}
            maxLength={40}
            placeholder="Bugiganga"
            className="
              p-2 mt-4 bg-transparent border rounded-md outline-none
              border-black border-opacity-10 focus:border-black focus:border-opacity-80
              dark:border-white dark:border-opacity-10 dark:focus:border-white dark:focus:border-opacity-80 
            "
          ></input>
        </div>
        <div className="flex mt-4 items-center justify-items-stretch">
          <ValidationError errorMessage={this.state.validationErrorMessage} />
          <button
            onClick={() => this.submitNewTracking()}
            disabled={this.state.isButtonDisabled}
            className="self-end p-2 rounded-md font-bold opacity-100 disabled:opacity-50 bg-black text-white dark:bg-white dark:text-black"
          >
            Rastrear
          </button>
        </div>
        <div className="mt-4 border-t border-black border-opacity-10 dark:border-white dark:border-opacity-10"></div>
        <MainBody isLoading={this.state.isLoading} trackings={this.state.trackings} />
      </>
    );
  }
}

const Description: React.FunctionComponent<{}> = () => {
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
    </>
  );
};

const MainBody: React.FunctionComponent<{ isLoading: boolean; trackings: TrackingViewData[] }> = ({
  isLoading,
  trackings
}) => {
  return (
    <div className="self-center">
      {(() => {
        if (isLoading) return <CircleLoading />;
        else return <Trackings trackings={trackings} />;
      })()}
    </div>
  );
};

const Trackings: React.FunctionComponent<{ trackings: TrackingViewData[] }> = ({ trackings }) => {
  if (!trackings) {
    return <></>;
  }

  return (
    <>
      {trackings.map((tracking, index) => (
        <div key={tracking.code}>
          <div className="flex flex-col sm:flex-row mt-4">
            <p className="text-xl font-bold mr-2 text-gray-600 dark:text-gray-400">{tracking.code}</p>
            <p className="text-xl font-bold">{tracking.name}</p>
          </div>
          <Events tracking={tracking} />
          {(() => {
            if (index == trackings.length - 1) return <></>;
            return (
              <div className="mt-4 border-t border-black border-opacity-10 dark:border-white dark:border-opacity-10"></div>
            );
          })()}
        </div>
      ))}
    </>
  );
};

const Events: React.FunctionComponent<{ tracking: TrackingViewData }> = ({ tracking }) => {
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
