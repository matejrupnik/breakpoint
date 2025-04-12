'use client'

import * as React from 'react';
import Map from '@/components/Map';

export default function Home() {
  return (
    <main className="flex min-h-screen flex-col items-center justify-center p-24">
      <Map />
    </main>
  );
}
