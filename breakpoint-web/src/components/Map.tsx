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

// Create a type for the map style keys
type MapStyleKey = keyof typeof MAP_STYLES;

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
  const [currentMapStyle, setCurrentMapStyle] = React.useState<MapStyleKey>('Streets');
  // Add state for layer visibility
  const [visibleLayers, setVisibleLayers] = React.useState({
    asphalt: true,
    gravel: true,
    rough: true,
    pothole: true
  });

  // Function to toggle visibility of a specific layer
  const toggleLayerVisibility = (layer: keyof typeof visibleLayers) => {
    setVisibleLayers(prev => ({
      ...prev,
      [layer]: !prev[layer]
    }));
  };

  // Function to toggle all layers on/off
  const toggleAllLayers = (visible: boolean) => {
    setVisibleLayers({
      asphalt: visible,
      gravel: visible,
      rough: visible,
      pothole: visible
    });
  };

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

      {/* Map style switcher - modern design */}
      <div style={{
        position: 'absolute',
        top: '20px',
        right: '20px',
        zIndex: 1000,
        backgroundColor: 'rgba(255, 255, 255, 0.9)',
        padding: '15px',
        borderRadius: '8px',
        boxShadow: '0 4px 12px rgba(0,0,0,0.15)',
        backdropFilter: 'blur(5px)',
        fontFamily: 'system-ui, -apple-system, sans-serif'
      }}>
        <div style={{ 
          fontWeight: '600', 
          marginBottom: '12px', 
          borderBottom: '1px solid rgba(0,0,0,0.1)', 
          paddingBottom: '8px',
          fontSize: '14px',
          color: '#333'
        }}>
          MAP STYLE
        </div>
        <select
          id="map-style-select"
          value={currentMapStyle}
          onChange={(e) => setCurrentMapStyle(e.target.value as MapStyleKey)}
          style={{
            width: '100%',
            padding: '8px 10px',
            borderRadius: '6px',
            border: '1px solid rgba(0,0,0,0.1)',
            backgroundColor: '#f8f8f8',
            fontSize: '13px',
            color: '#333',
            cursor: 'pointer',
            outline: 'none',
            boxShadow: '0 1px 3px rgba(0,0,0,0.05)',
            appearance: 'none',
            backgroundImage: 'url("data:image/svg+xml;charset=US-ASCII,%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20width%3D%22292.4%22%20height%3D%22292.4%22%3E%3Cpath%20fill%3D%22%23333%22%20d%3D%22M287%2069.4a17.6%2017.6%200%200%200-13-5.4H18.4c-5%200-9.3%201.8-12.9%205.4A17.6%2017.6%200%200%200%200%2082.2c0%205%201.8%209.3%205.4%2012.9l128%20127.9c3.6%203.6%207.8%205.4%2012.8%205.4s9.2-1.8%2012.8-5.4L287%2095c3.5-3.5%205.4-7.8%205.4-12.8%200-5-1.9-9.2-5.5-12.8z%22%2F%3E%3C%2Fsvg%3E")',
            backgroundRepeat: 'no-repeat',
            backgroundPosition: 'right 10px top 50%',
            backgroundSize: '12px auto',
            paddingRight: '28px'
          }}
        >
          {Object.keys(MAP_STYLES).map(style => (
            <option key={style} value={style}>{style}</option>
          ))}
        </select>
      </div>

      {/* Layer visibility toggles - modern sleek design */}
      <div style={{
        position: 'absolute',
        bottom: '20px',
        left: '20px',
        zIndex: 1000,
        backgroundColor: 'rgba(255, 255, 255, 0.9)',
        padding: '15px',
        borderRadius: '8px',
        boxShadow: '0 4px 12px rgba(0,0,0,0.15)',
        backdropFilter: 'blur(5px)',
        minWidth: '180px',
        fontFamily: 'system-ui, -apple-system, sans-serif'
      }}>
        <div style={{ 
          fontWeight: '600', 
          marginBottom: '12px', 
          borderBottom: '1px solid rgba(0,0,0,0.1)', 
          paddingBottom: '8px',
          fontSize: '14px',
          color: '#333'
        }}>
          SURFACE TYPES
        </div>
        
        {/* Asphalt Toggle */}
        <div style={{ 
          display: 'flex', 
          alignItems: 'center', 
          justifyContent: 'space-between',
          marginBottom: '10px',
          cursor: 'pointer'
        }} onClick={() => toggleLayerVisibility('asphalt')}>
          <div style={{ display: 'flex', alignItems: 'center' }}>
            <div style={{ 
              width: '12px', 
              height: '12px', 
              backgroundColor: 'rgb(124, 207, 0)', 
              borderRadius: '50%', 
              marginRight: '10px',
              border: '2px solid white',
              boxShadow: '0 0 0 1px rgba(0,0,0,0.1)'
            }}></div>
            <span style={{ fontSize: '13px', color: '#333' }}>Asphalt</span>
          </div>
          <div style={{
            width: '36px',
            height: '20px',
            backgroundColor: visibleLayers.asphalt ? 'rgb(124, 207, 0)' : '#e0e0e0',
            borderRadius: '10px',
            position: 'relative',
            transition: 'background-color 0.2s',
          }}>
            <div style={{
              width: '16px',
              height: '16px',
              backgroundColor: 'white',
              borderRadius: '50%',
              position: 'absolute',
              top: '2px',
              left: visibleLayers.asphalt ? '18px' : '2px',
              transition: 'left 0.2s',
              boxShadow: '0 1px 2px rgba(0,0,0,0.3)'
            }}></div>
          </div>
        </div>
        
        {/* Gravel Toggle */}
        <div style={{ 
          display: 'flex', 
          alignItems: 'center', 
          justifyContent: 'space-between',
          marginBottom: '10px',
          cursor: 'pointer'
        }} onClick={() => toggleLayerVisibility('gravel')}>
          <div style={{ display: 'flex', alignItems: 'center' }}>
            <div style={{ 
              width: '12px', 
              height: '12px', 
              backgroundColor: 'rgb(255, 223, 32)', 
              borderRadius: '50%', 
              marginRight: '10px',
              border: '2px solid white',
              boxShadow: '0 0 0 1px rgba(0,0,0,0.1)'
            }}></div>
            <span style={{ fontSize: '13px', color: '#333' }}>Gravel</span>
          </div>
          <div style={{
            width: '36px',
            height: '20px',
            backgroundColor: visibleLayers.gravel ? 'rgb(255, 223, 32)' : '#e0e0e0',
            borderRadius: '10px',
            position: 'relative',
            transition: 'background-color 0.2s',
          }}>
            <div style={{
              width: '16px',
              height: '16px',
              backgroundColor: 'white',
              borderRadius: '50%',
              position: 'absolute',
              top: '2px',
              left: visibleLayers.gravel ? '18px' : '2px',
              transition: 'left 0.2s',
              boxShadow: '0 1px 2px rgba(0,0,0,0.3)'
            }}></div>
          </div>
        </div>
        
        {/* Rough Toggle */}
        <div style={{ 
          display: 'flex', 
          alignItems: 'center', 
          justifyContent: 'space-between',
          marginBottom: '10px',
          cursor: 'pointer'
        }} onClick={() => toggleLayerVisibility('rough')}>
          <div style={{ display: 'flex', alignItems: 'center' }}>
            <div style={{ 
              width: '12px', 
              height: '12px', 
              backgroundColor: 'rgb(255, 137, 4)', 
              borderRadius: '50%', 
              marginRight: '10px',
              border: '2px solid white',
              boxShadow: '0 0 0 1px rgba(0,0,0,0.1)'
            }}></div>
            <span style={{ fontSize: '13px', color: '#333' }}>Rough</span>
          </div>
          <div style={{
            width: '36px',
            height: '20px',
            backgroundColor: visibleLayers.rough ? 'rgb(255, 137, 4)' : '#e0e0e0',
            borderRadius: '10px',
            position: 'relative',
            transition: 'background-color 0.2s',
          }}>
            <div style={{
              width: '16px',
              height: '16px',
              backgroundColor: 'white',
              borderRadius: '50%',
              position: 'absolute',
              top: '2px',
              left: visibleLayers.rough ? '18px' : '2px',
              transition: 'left 0.2s',
              boxShadow: '0 1px 2px rgba(0,0,0,0.3)'
            }}></div>
          </div>
        </div>
        
        {/* Pothole Toggle */}
        <div style={{ 
          display: 'flex', 
          alignItems: 'center', 
          justifyContent: 'space-between',
          marginBottom: '15px',
          cursor: 'pointer'
        }} onClick={() => toggleLayerVisibility('pothole')}>
          <div style={{ display: 'flex', alignItems: 'center' }}>
            <div style={{ 
              width: '12px', 
              height: '12px', 
              backgroundColor: 'rgb(251, 44, 54)', 
              borderRadius: '50%', 
              marginRight: '10px',
              border: '2px solid white',
              boxShadow: '0 0 0 1px rgba(0,0,0,0.1)'
            }}></div>
            <span style={{ fontSize: '13px', color: '#333' }}>Pothole</span>
          </div>
          <div style={{
            width: '36px',
            height: '20px',
            backgroundColor: visibleLayers.pothole ? 'rgb(251, 44, 54)' : '#e0e0e0',
            borderRadius: '10px',
            position: 'relative',
            transition: 'background-color 0.2s',
          }}>
            <div style={{
              width: '16px',
              height: '16px',
              backgroundColor: 'white',
              borderRadius: '50%',
              position: 'absolute',
              top: '2px',
              left: visibleLayers.pothole ? '18px' : '2px',
              transition: 'left 0.2s',
              boxShadow: '0 1px 2px rgba(0,0,0,0.3)'
            }}></div>
          </div>
        </div>
        
        {/* Toggle All Buttons */}
        <div style={{ 
          display: 'flex', 
          justifyContent: 'space-between', 
          marginTop: '8px',
          borderTop: '1px solid rgba(0,0,0,0.1)',
          paddingTop: '12px'
        }}>
          <button 
            onClick={(e) => {
              e.stopPropagation();
              toggleAllLayers(true);
            }} 
            style={{ 
              padding: '6px 12px', 
              backgroundColor: '#f8f8f8', 
              border: 'none', 
              borderRadius: '6px',
              cursor: 'pointer',
              fontSize: '12px',
              fontWeight: '500',
              color: '#333',
              boxShadow: '0 1px 3px rgba(0,0,0,0.1)',
              transition: 'all 0.2s'
            }}
          >
            Show All
          </button>
          <button 
            onClick={(e) => {
              e.stopPropagation();
              toggleAllLayers(false);
            }} 
            style={{ 
              padding: '6px 12px', 
              backgroundColor: '#f8f8f8', 
              border: 'none', 
              borderRadius: '6px',
              cursor: 'pointer',
              fontSize: '12px',
              fontWeight: '500',
              color: '#333',
              boxShadow: '0 1px 3px rgba(0,0,0,0.1)',
              transition: 'all 0.2s'
            }}
          >
            Hide All
          </button>
        </div>
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

        {gravelData && visibleLayers.gravel && (
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

        {asphaltData && visibleLayers.asphalt && (
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

        {roughData && visibleLayers.rough && (
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

        {potholeData && visibleLayers.pothole && (
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