import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "华典智谱",
  description: "中国古籍 AI 知识平台",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="zh-CN">
      <body className="min-h-screen antialiased">{children}</body>
    </html>
  );
}
