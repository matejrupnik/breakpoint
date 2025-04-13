import * as React from 'react';
import Map from '@/components/Map';
import { getHeatmap } from '@/api/getHeatmap';

export default async function Home() {

  const heatmapData = await getHeatmap();

  return (
    <main className="w-screen h-screen overflow-hidden">
      <Map heatmapData={heatmapData} />
    </main>
  );
}
