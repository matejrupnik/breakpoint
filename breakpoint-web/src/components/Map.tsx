'use client'

import * as React from 'react';
import MapGL, { Marker, Source, Layer } from 'react-map-gl/mapbox';
import 'mapbox-gl/dist/mapbox-gl.css';
import { Heatmap, SurfaceReading } from '../types/pothole';
import { getPotholes } from '../services/potholeService';

interface MapProps {
  longitude?: number;
  latitude?: number;
  zoom?: number;
  fullscreen?: boolean;
  heatmapData?: Heatmap;
}

export default function Map({
  longitude = 14.50,
  latitude = 46.05,
  zoom = 12,
  fullscreen = true,
  heatmapData,
}: MapProps) {
//   const [potholes, setPotholes] = React.useState<Pothole[]>([]);
  const [error, setError] = React.useState<string | null>(null);
  const [mapCenter, setMapCenter] = React.useState({ longitude, latitude });
  const [dimensions, setDimensions] = React.useState({ width: '100vw', height: '100vh' });
  
  // Create GeoJSON line data from heatmapData
  const asphaltLineData = React.useMemo(() => {
    if (!heatmapData || heatmapData.asphalt.length < 2) return null;
    
    return {
      type: 'FeatureCollection' as const,
      features: [
        {
          type: 'Feature' as const,
          properties: {},
          geometry: {
            type: 'LineString' as const,
            coordinates: heatmapData.asphalt.map(point => [point.longitude, point.latitude])
          }
        }
      ]
    };
  }, [heatmapData]);
    
  const gravelLineData = React.useMemo(() => {
    if (!heatmapData || heatmapData.gravel.length < 2) return null;
    
    return {
      type: 'FeatureCollection' as const,
      features: [
        {
          type: 'Feature' as const,
          properties: {},
          geometry: {
            type: 'LineString' as const,
            coordinates: heatmapData.gravel.map(point => [point.longitude, point.latitude])
          }
        }
      ]
    };
  }, [heatmapData]);
    
  const roughLineData = React.useMemo(() => {
    if (!heatmapData || heatmapData.rough.length < 2) return null;
    
    return {
      type: 'FeatureCollection' as const,
      features: [
        {
          type: 'Feature' as const,
          properties: {},
          geometry: {
            type: 'LineString' as const,
            coordinates: heatmapData.rough.map(point => [point.longitude, point.latitude])
          }
        }
      ]
    };
  }, [heatmapData]);
    

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
        {/* Add the lines connecting points */}
        {asphaltLineData && (
          <Source id="asphalt-line" type="geojson" data={asphaltLineData}>
            <Layer
              id="asphalt-layer"
              type="line"
              paint={{
                'line-color': '#22ff00',
                'line-width': 10,
              }}
            />
          </Source>
        )}
              
        {gravelLineData && (
          <Source id="gravel-line" type="geojson" data={gravelLineData}>
            <Layer
              id="gravel-layer"
              type="line"
              paint={{
                'line-color': '#f6ff00',
                'line-width': 10,
              }}
            />
          </Source>
        )}
              
        {roughLineData && (
          <Source id="rough-line" type="geojson" data={roughLineData}>
            <Layer
              id="rough-layer"
              type="line"
              paint={{
                'line-color': '#ff4400',
                'line-width': 10,
              }}
            />
          </Source>
        )}
        
        {/* Render the individual markers */}
              {heatmapData?.pothole.map((pothole) => {
                  console.log(pothole)
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
                  backgroundColor: "rgba(0, 123, 255, 0.8)",
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
        )})}
      </MapGL>
    </div>
  );
}