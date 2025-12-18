import { Think } from "ui/think";
import { getTranslations } from "next-intl/server";
import { FlipWords } from "ui/flip-words";
import { BackgroundRippleEffect } from "ui/background-ripple-effect";

export default async function AuthLayout({
  children,
}: { children: React.ReactNode }) {
  const t = await getTranslations("Auth.Intro");
  return (
    <main className="relative w-full h-screen flex flex-col items-center justify-center overflow-hidden">
      <div className="absolute inset-0 z-0">
        <BackgroundRippleEffect />
      </div>

      <div className="relative z-10 w-full max-w-md p-8 bg-background/50 backdrop-blur-sm rounded-lg border border-border/50">
        <div className="flex flex-col items-center mb-8">
          <h1 className="text-2xl font-semibold flex items-center gap-3 animate-in fade-in duration-1000 mb-2">
            <Think />
            <span>Chat Bot</span>
          </h1>
          <FlipWords
            words={[t("description")]}
            className="text-muted-foreground text-center"
          />
        </div>
        {children}
      </div>
    </main>
  );
}
