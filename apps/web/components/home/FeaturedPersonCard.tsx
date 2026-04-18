import Link from "next/link";

import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";

interface FeaturedPersonCardProps {
  slug: string;
  name: string;
  dynasty?: string | null;
  biography?: string | null;
}

export function FeaturedPersonCard({
  slug,
  name,
  dynasty,
  biography,
}: FeaturedPersonCardProps) {
  const excerpt = biography ? biography.slice(0, 60) + (biography.length > 60 ? "..." : "") : null;

  return (
    <Link href={`/persons/${slug}`} className="block transition-transform hover:scale-[1.02]">
      <Card className="h-full">
        <CardHeader className="pb-2">
          <CardTitle className="text-lg">{name}</CardTitle>
          {dynasty && (
            <p className="text-sm text-muted-foreground">{dynasty}</p>
          )}
        </CardHeader>
        {excerpt && (
          <CardContent>
            <p className="text-sm text-muted-foreground">{excerpt}</p>
          </CardContent>
        )}
      </Card>
    </Link>
  );
}
