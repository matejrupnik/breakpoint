'use client'

import * as React from 'react';
import MapGL, { Marker, Source, Layer } from 'react-map-gl/mapbox';
import 'mapbox-gl/dist/mapbox-gl.css';
import { Heatmap, SurfaceReading } from '../types/pothole';
import { getHeatmap } from '../api/getHeatmap';

interface MapProps {
  longitude?: number;
  latitude?: number;
  zoom?: number;
  fullscreen?: boolean;
  heatmapData?: Heatmap;
  refreshInterval?: number; // Added refresh interval prop in seconds
}

export default function Map({
  longitude = 14.50,
  latitude = 46.05,
  zoom = 12,
  fullscreen = true,
  heatmapData: initialHeatmapData,
  refreshInterval = 5, // Default to 10 seconds
}: MapProps) {
  const [error, setError] = React.useState<string | null>(null);
  const [mapCenter, setMapCenter] = React.useState({ longitude, latitude });
  const [dimensions, setDimensions] = React.useState({ width: '100vw', height: '100vh' });
  const [heatmapData, setHeatmapData] = React.useState<Heatmap | undefined>(initialHeatmapData);
  const [isRefreshing, setIsRefreshing] = React.useState<boolean>(false);
  
  // Function to fetch the latest heatmap data
  const refreshHeatmapData = React.useCallback(async () => {
    
    try {
      setIsRefreshing(true);
      // Use the existing getHeatmap function from our API
      const newData = await getHeatmap();
      setHeatmapData(newData);
      setError(null);
    } catch (err) {
      console.error('Error refreshing heatmap data:', err);
      setError('Failed to refresh map data. Will try again.');
    } finally {
      setIsRefreshing(false);
    }
  }, []);

  // Set up the periodic refresh
  React.useEffect(() => {
    // Skip if no refresh is desired or no initial data
    if (refreshInterval <= 0) return;
    
    console.log(`Setting up refresh interval: ${refreshInterval} seconds`);
    
    // Initial load if no heatmapData was provided
    if (!initialHeatmapData && !isRefreshing) {
      refreshHeatmapData();
    }
    
    // Set up interval for periodic updates
    const intervalId = setInterval(() => {
      console.log('Refreshing heatmap data...');
      refreshHeatmapData();
    }, refreshInterval * 1000);
    
    // Clean up interval on component unmount
    return () => {
      console.log('Cleaning up refresh interval');
      clearInterval(intervalId);
    };
  }, [refreshInterval, refreshHeatmapData, initialHeatmapData, isRefreshing]);
  
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
        
        {/* Render the individual markers */}
              {heatmapData?.pothole.map((pothole) => {
                  return (
          <Marker
            key={pothole.id}
            longitude={pothole.longitude}
            latitude={pothole.latitude}
          >
            <div className="marker-container" style={{ position: 'relative' }}>
              {/* Pulsating marker */}
              <div
                // className="pulsating-marker"
                style={{
                  width: '32px',
                  height: '32px',
                  borderRadius: '50%',
                  backgroundColor: "rgba(183, 0, 0, 0.8)",
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
        {heatmapData?.asphalt.map((pothole) => {
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
                  width: '10px',
                  height: '10px',
                  borderRadius: '50%',
                  backgroundColor: "rgba(0, 255, 21, 0.8)",
                  // border: '2px solid white',
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
        {heatmapData?.gravel.map((pothole) => {
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
                  width: '10px',
                  height: '10px',
                  borderRadius: '50%',
                  backgroundColor: "rgba(255, 238, 0, 0.8)",
                  // border: '2px solid white',
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
        {heatmapData?.rough.map((pothole) => {
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
                  width: '10px',
                  height: '10px',
                  borderRadius: '50%',
                  backgroundColor: "rgba(255, 106, 0, 0.8)",
                  // border: '2px solid white',
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