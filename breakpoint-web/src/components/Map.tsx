'use client'

import * as React from 'react';
import MapGL, { Source, Layer, Marker, NavigationControl } from 'react-map-gl/mapbox';
import 'mapbox-gl/dist/mapbox-gl.css';
import { Heatmap, SurfaceReading } from '../types/pothole';
import { getHeatmap } from '../api/getHeatmap';

// Define available map styles
const MAP_STYLES = {
  'Streets': 'mapbox://styles/mapbox/streets-v11',
  'Light': 'mapbox://styles/mapbox/light-v11',
  'Dark': 'mapbox://styles/mapbox/dark-v11',
  'Satellite': 'mapbox://styles/mapbox/satellite-v9',
  'Satellite Streets': 'mapbox://styles/mapbox/satellite-streets-v12',
  'Navigation Day': 'mapbox://styles/mapbox/navigation-day-v1',
  'Navigation Night': 'mapbox://styles/mapbox/navigation-night-v1',
  'Outdoors': 'mapbox://styles/mapbox/outdoors-v12',
};

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
  const [hoveredFeature, setHoveredFeature] = React.useState<SurfaceReading | null>(null);
  const [currentMapStyle, setCurrentMapStyle] = React.useState<string>('Streets');

  // Function to fetch the latest heatmap data
  const refreshHeatmapData = React.useCallback(async () => {
    try {
      setIsRefreshing(true);
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
    if (refreshInterval <= 0) return;

    console.log(`Setting up refresh interval: ${refreshInterval} seconds`);

    if (!initialHeatmapData && !isRefreshing) {
      refreshHeatmapData();
    }

    const intervalId = setInterval(() => {
      console.log('Refreshing heatmap data...');
      refreshHeatmapData();
    }, refreshInterval * 1000);

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

  // Create GeoJSON point data for each category
  const createPointGeoJSON = React.useCallback((points: SurfaceReading[]) => {
    if (!points || points.length === 0) return null;

    return {
      type: 'FeatureCollection' as const,
      features: points.map(point => ({
        type: 'Feature' as const,
        properties: {
          id: point.id,
          latitude: point.latitude,
          longitude: point.longitude
        },
        geometry: {
          type: 'Point' as const,
          coordinates: [point.longitude, point.latitude]
        }
      }))
    };
  }, []);

  const potholeData = React.useMemo(() => createPointGeoJSON(heatmapData?.pothole || []), [heatmapData?.pothole, createPointGeoJSON]);
  const asphaltData = React.useMemo(() => createPointGeoJSON(heatmapData?.asphalt || []), [heatmapData?.asphalt, createPointGeoJSON]);
  const gravelData = React.useMemo(() => createPointGeoJSON(heatmapData?.gravel || []), [heatmapData?.gravel, createPointGeoJSON]);
  const roughData = React.useMemo(() => createPointGeoJSON(heatmapData?.rough || []), [heatmapData?.rough, createPointGeoJSON]);

  // Effect to handle viewport size for fullscreen map
  React.useEffect(() => {
    if (fullscreen) {
      const updateDimensions = () => {
        setDimensions({
          width: '100vw',
          height: '100vh'
        });
      };

      updateDimensions();

      window.addEventListener('resize', updateDimensions);

      return () => {
        window.removeEventListener('resize', updateDimensions);
      };
    }
  }, [fullscreen]);

  const onMouseEnter = React.useCallback((event: any) => {
    if (event.features && event.features.length > 0) {
      // Check if the hovered layer is the pothole layer
      if (event.features[0].layer.id === 'pothole-layer') {
        const { properties } = event.features[0];
        setHoveredFeature({
          id: properties.id,
          latitude: properties.latitude,
          longitude: properties.longitude
        });
      }
    }
  }, []);

  const onMouseLeave = React.useCallback(() => {
    setHoveredFeature(null);
  }, []);

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
          backgroundColor: 'var)',
          textAlign: 'center',
          color: 'red'
        }}>
          {error}
        </div>
      )}

      {/* Map style switcher */}
      <div style={{
        position: 'absolute',
        top: '10px',
        right: '10px',
        zIndex: 1000,
        backgroundColor: 'white',
        padding: '10px',
        borderRadius: '4px',
        boxShadow: '0 2px 4px rgba(0,0,0,0.3)'
      }}>
        <label htmlFor="map-style-select" style={{ marginRight: '10px' }}>Map Style:</label>
        <select
          id="map-style-select"
          value={currentMapStyle}
          onChange={(e) => setCurrentMapStyle(e.target.value)}
        >
          {Object.keys(MAP_STYLES).map(style => (
            <option key={style} value={style}>{style}</option>
          ))}
        </select>
      </div>

      <MapGL
        mapboxAccessToken={process.env.NEXT_PUBLIC_MAPBOX_ACCESS_TOKEN}
        initialViewState={{
          longitude: mapCenter.longitude,
          latitude: mapCenter.latitude,
          zoom,
          pitch: 45, // Add a default pitch for 3D effect
          bearing: 0
        }}
        style={{ width: '100%', height: '100%' }}
        mapStyle={MAP_STYLES[currentMapStyle]} // Use selected map style
        terrain={{ source: 'mapbox-dem', exaggeration: 1.5 }} // Add terrain
        interactiveLayerIds={[
          'pothole-layer' // Only pothole layer is interactive now
        ]}
        onMouseEnter={onMouseEnter}
        onMouseLeave={onMouseLeave}
      >
        <NavigationControl position="top-left" />

        {/* Add terrain source */}
        <Source
          id="mapbox-dem"
          type="raster-dem"
          url="mapbox://mapbox.mapbox-terrain-dem-v1"
          tileSize={512}
          maxzoom={14}
        />

        {/* Add 3D buildings */}
        <Source id="composite" type="vector" url="mapbox://mapbox.mapbox-streets-v8">
          <Layer
            id="3d-buildings"
            source-layer="building"
            type="fill-extrusion"
            minzoom={15}
            paint={{
              'fill-extrusion-color': '#aaa',
              'fill-extrusion-height': [
                'interpolate', ['linear'], ['zoom'],
                15, 0,
                16, ['get', 'height']
              ],
              'fill-extrusion-base': ['get', 'min_height'],
              'fill-extrusion-opacity': 0.6
            }}
          />
        </Source>

        {gravelData && (
          <Source id="gravel-source" type="geojson" data={gravelData}>
            <Layer
              id="gravel-layer"
              type="circle"
              paint={{
                'circle-radius': [
                  'interpolate', ['linear'], ['zoom'],
                  10, 3,
                  15, 5,
                  20, 8
                ],
                'circle-color': 'rgb(255, 223, 32)',
              }}
            />
          </Source>
        )}

        {asphaltData && (
          <Source id="asphalt-source" type="geojson" data={asphaltData}>
            <Layer
              id="asphalt-layer"
              type="circle"
              paint={{
                'circle-radius': [
                  'interpolate', ['linear'], ['zoom'],
                  10, 3,
                  15, 5,
                  20, 8
                ],
                'circle-color': 'rgb(124, 207, 0)',
              }}
            />
          </Source>
        )}

        {roughData && (
          <Source id="rough-source" type="geojson" data={roughData}>
            <Layer
              id="rough-layer"
              type="circle"
              paint={{
                'circle-radius': [
                  'interpolate', ['linear'], ['zoom'],
                  10, 3,
                  15, 6,
                  20, 9
                ],
                'circle-color': 'rgb(255, 137, 4)',
              }}
            />
          </Source>
        )}

        {potholeData && (
          <Source id="pothole-source" type="geojson" data={potholeData}>
            <Layer
              id="pothole-layer"
              type="circle"
              paint={{
                'circle-radius': [
                  'interpolate', ['linear'], ['zoom'],
                  10, 5,
                  15, 16,
                  20, 25
                ],
                'circle-color': 'rgb(251, 44, 54)',
                'circle-translate': [0, 0],
                'circle-translate-anchor': 'viewport',
                'circle-pitch-alignment': 'map',
                'circle-pitch-scale': 'map'
              }}
            />
            {/* Add a shadow layer for 3D effect */}
            <Layer
              id="pothole-shadow"
              type="circle"
              paint={{
                'circle-radius': [
                  'interpolate', ['linear'], ['zoom'],
                  10, 7,
                  15, 18,
                  20, 27
                ],
                'circle-opacity': 0,
                'circle-color': '#000',
                'circle-blur': 1,
                'circle-translate': [3, 3],
                'circle-translate-anchor': 'viewport',
                'circle-pitch-alignment': 'map',
                'circle-pitch-scale': 'map'
              }}
            />
          </Source>
        )}

        {hoveredFeature && (
          <Marker
            longitude={hoveredFeature.longitude}
            latitude={hoveredFeature.latitude}
            offset={[0, -10]}
          >
            <div style={{
              position: 'absolute',
              backgroundColor: 'white',
              padding: '5px',
              borderRadius: '4px',
              boxShadow: '0 2px 4px rgba(0,0,0,0.3)',
              zIndex: 1000,
              pointerEvents: 'none',
              transform: 'translate(-50%, -100%)',
              marginBottom: '10px'
            }}>
              <strong>Location:</strong> {hoveredFeature.latitude.toFixed(6)}, {hoveredFeature.longitude.toFixed(6)}
            </div>
          </Marker>
        )}
      </MapGL>
    </div>
  );
}