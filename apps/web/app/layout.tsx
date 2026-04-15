import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "华典智谱",
  description: "中国古籍 AI 知识平台",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="zh-CN">
      <body>{children}</body>
    </html>
  );
}
