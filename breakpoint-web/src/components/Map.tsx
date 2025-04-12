'use client'

import * as React from 'react';
import MapGL, { Marker } from 'react-map-gl/mapbox';
import 'mapbox-gl/dist/mapbox-gl.css';
import { Pothole } from '../types/pothole';
import { getPotholes } from '../services/potholeService';

interface MapProps {
  longitude?: number;
  latitude?: number;
  zoom?: number;
  width?: number | string;
  height?: number | string;
}

export default function Map({
  longitude = -100,
  latitude = 40,
  zoom = 3.5,
  width = 600,
  height = 400
}: MapProps) {
  const [potholes, setPotholes] = React.useState<Pothole[]>([]);
  const [isLoading, setIsLoading] = React.useState(true);
  const [error, setError] = React.useState<string | null>(null);

  React.useEffect(() => {
    async function fetchPotholes() {
      try {
        setIsLoading(true);
        const data = await getPotholes();
        setPotholes(data);
      } catch (err) {
        console.error('Failed to fetch potholes:', err);
        setError('Failed to load pothole data');
      } finally {
        setIsLoading(false);
      }
    }

    fetchPotholes();
  }, []);

  return (
    <div>
      {isLoading && <div>Loading pothole data...</div>}
      {error && <div style={{ color: 'red' }}>{error}</div>}
      
      <MapGL
        mapboxAccessToken={process.env.NEXT_PUBLIC_MAPBOX_ACCESS_TOKEN}
        initialViewState={{
          longitude,
          latitude,
          zoom
        }}
        style={{width, height}}
        mapStyle="mapbox://styles/mapbox/streets-v9"
      >
        {potholes.map((pothole) => (
          <Marker 
            key={pothole.id}
            longitude={pothole.longitude}
            latitude={pothole.latitude}
          >
            <div 
              style={{
                width: '20px',
                height: '20px',
                borderRadius: '50%',
                backgroundColor: 
                  pothole.severity === 'high' ? 'red' : 
                  pothole.severity === 'medium' ? 'orange' : 'yellow',
                border: '2px solid white',
                cursor: 'pointer'
              }}
              title={`Pothole ID: ${pothole.id}, Severity: ${pothole.severity}`}
            />
          </Marker>
        ))}
      </MapGL>
    </div>
  );
}