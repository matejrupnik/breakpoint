'use client'

import * as React from 'react';
import MapGL, { Marker } from 'react-map-gl/mapbox';
import 'mapbox-gl/dist/mapbox-gl.css';
import { Heatmap, Pothole } from '../types/pothole';
import { getPotholes } from '../services/potholeService';

interface MapProps {
  longitude?: number;
  latitude?: number;
  zoom?: number;
    fullscreen?: boolean;
    heatmapData?: Pothole[];
}

export default function Map({
  longitude = -100,
  latitude = 40,
  zoom = 3.5,
    fullscreen = true,
  heatmapData,
}: MapProps) {
  const [potholes, setPotholes] = React.useState<Pothole[]>([]);
  const [error, setError] = React.useState<string | null>(null);
  const [mapCenter, setMapCenter] = React.useState({ longitude, latitude });
    const [dimensions, setDimensions] = React.useState({ width: '100vw', height: '100vh' });
    
    // console.log(heatmapData)

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

//     React.useEffect(() => {
//     async function fetchPotholes() {
//       try {
//         setIsLoading(true);
//         const data = await getPotholes();
//         setPotholes(data);
        
//         // If we have pothole data, adjust the map center to the first pothole
//         if (data.length > 0) {
//           setMapCenter({
//             longitude: data[0].longitude,
//             latitude: data[0].latitude
//           });
//         }
//       } catch (err) {
//         console.error('Failed to fetch potholes:', err);
//         setError('Failed to load pothole data. Using fallback data.');
//       } finally {
//         setIsLoading(false);
//       }
//     }

//     fetchPotholes();
//   }, []);

  // Determine marker color based on severity
  const getMarkerColor = (severity?: string) => {
    switch(severity) {
      case 'high': return 'rgba(255, 0, 0, 0.8)';
      case 'medium': return 'rgba(255, 165, 0, 0.8)';
      case 'low': return 'rgba(255, 255, 0, 0.8)';
      default: return 'rgba(0, 0, 255, 0.8)';
    }
  };

  return (
    <div className="map-container" style={{ position: 'relative', width: dimensions.width, height: dimensions.height }}>
      
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
              {heatmapData?.map((pothole) => {
                //   console.log(pothole)
                  return (
                      <Marker
                          key={pothole.id}
                          longitude={pothole.longitude}
                          latitude={pothole.latitude}
                      >
                          <div className="marker-container" style={{ position: 'relative' }}>
                              {/* Pulsating marker */}
                              <div
                                  className="pulsating-marker"
                                  style={{
                                      width: '18px',
                                      height: '18px',
                                      borderRadius: '50%',
                                      backgroundColor: "rgba(255, 0, 0, 0.8)",
                                      border: '2px solid white',
                                      cursor: 'pointer'
                                  }}
                              />
              
                              {/* Tooltip that appears on hover */}
                              <div className="marker-tooltip">
                                  <strong>Pothole ID:</strong> {pothole.id}<br />
                                  {/* {pothole.severity && (
                  <>
                    <strong>Severity:</strong> {pothole.severity.charAt(0).toUpperCase() + pothole.severity.slice(1)}<br />
                  </>
                )} */}
                                  <strong>Location:</strong> {pothole.latitude.toFixed(6)}, {pothole.longitude.toFixed(6)}
                              </div>
                          </div>
                      </Marker>
                  )
              })}
      </MapGL>
      
    </div>
  );
}