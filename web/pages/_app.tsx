import React from "react";
import { ThemeProvider } from "next-themes";
import "tailwindcss/tailwind.css";
import Page from "@/components/Page";

function MyApp({ Component, pageProps }) {
  return (
    <ThemeProvider attribute="class">
      <Page>
        <Component {...pageProps} />
      </Page>
    </ThemeProvider>
  );
}

export default MyApp;
