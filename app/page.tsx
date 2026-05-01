import { AppShell } from "@/components/layout/app-shell";
import { BbsPageContent } from "@/components/bbs/page-content";

export default function HomePage() {
  return (
    <AppShell title="掲示板">
      <BbsPageContent />
    </AppShell>
  );
}
