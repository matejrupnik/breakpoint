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
  fullscreen?: boolean;
}

export default function Map({
  longitude = -100,
  latitude = 40,
  zoom = 3.5,
  fullscreen = true
}: MapProps) {
  const [potholes, setPotholes] = React.useState<Pothole[]>([]);
  const [isLoading, setIsLoading] = React.useState(true);
  const [error, setError] = React.useState<string | null>(null);
  const [mapCenter, setMapCenter] = React.useState({ longitude, latitude });
  const [dimensions, setDimensions] = React.useState({ width: '100vw', height: '100vh' });

  // Effect to handle viewport size for fullscreen map
  React.useEffect(() => {
    if (fullscreen) {
      const updateDimensions = () => {
        setDimensions({
          width: '100vw',
          height: '100vh'
        });
      };
      
      // Set initial dimensions
      updateDimensions();
      
      // Update dimensions when window is resized
      window.addEventListener('resize', updateDimensions);
      
      return () => {
        window.removeEventListener('resize', updateDimensions);
      };
    }
  }, [fullscreen]);

  React.useEffect(() => {
    async function fetchPotholes() {
      try {
        setIsLoading(true);
        const data = await getPotholes();
        setPotholes(data);
        
        // If we have pothole data, adjust the map center to the first pothole
        if (data.length > 0) {
          setMapCenter({
            longitude: data[0].longitude,
            latitude: data[0].latitude
          });
        }
      } catch (err) {
        console.error('Failed to fetch potholes:', err);
        setError('Failed to load pothole data. Using fallback data.');
      } finally {
        setIsLoading(false);
      }
    }

    fetchPotholes();
  }, []);

  // Determine marker color based on severity
  const getMarkerColor = (severity?: string) => {
    switch(severity) {
      case 'high': return 'red';
      case 'medium': return 'orange';
      case 'low': return 'yellow';
      default: return 'blue'; // Default color for unknown severity
    }
  };

  return (
    <div className="map-container" style={{ position: 'relative', width: dimensions.width, height: dimensions.height }}>
      {isLoading && (
        <div className="loading-overlay" style={{ 
          position: 'absolute', 
          top: 0, 
          left: 0, 
          right: 0, 
          zIndex: 10, 
          padding: '10px', 
          backgroundColor: 'rgba(255,255,255,0.7)',
          textAlign: 'center' 
        }}>
          Loading pothole data...
        </div>
      )}
      
      {error && (
        <div className="error-overlay" style={{ 
          position: 'absolute', 
          top: 0, 
          left: 0, 
          right: 0, 
          zIndex: 10, 
          padding: '10px', 
          backgroundColor: 'rgba(255,200,200,0.7)',
          textAlign: 'center',
          color: 'red'
        }}>
          {error}
        </div>
      )}
      
      <MapGL
        mapboxAccessToken={process.env.NEXT_PUBLIC_MAPBOX_ACCESS_TOKEN}
        initialViewState={{
          longitude: mapCenter.longitude,
          latitude: mapCenter.latitude,
          zoom
        }}
        style={{ width: '100%', height: '100%' }}
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
                // backgroundColor: getMarkerColor(pothole.severity),
                border: '2px solid white',
                cursor: 'pointer'
              }}
            //   title={`Pothole ID: ${pothole.id}${pothole.severity ? `, Severity: ${pothole.severity}` : ''}`}
            />
          </Marker>
        ))}
      </MapGL>
      
      {/* <div className="info-overlay" style={{ 
        position: 'absolute', 
        bottom: 0, 
        left: 0, 
        right: 0, 
        zIndex: 10, 
        padding: '10px', 
        backgroundColor: 'rgba(255,255,255,0.7)',
        textAlign: 'center'
      }}>
        {potholes.length > 0 ? (
          <p>Showing {potholes.length} potholes from API</p>
        ) : (
          !isLoading && <p>No potholes found</p>
        )}
      </div> */}
    </div>
  );
}