import { Heatmap, Pothole } from './../types/pothole';

export async function getHeatmap(): Promise<Pothole[]> {
  try {
    // Call the real API endpoint
    const response = await fetch('http://165.232.115.82:4000/api/heatmap?longitude=14.50&latitude=46.05');
    
    if (!response.ok) {
      throw new Error(`API error: ${response.status}`);
    }
    
      const data = await response.json();
      
      console.log(data.heatmap.surfaces);
    
    // Transform the API response to match our Pothole interface if needed
    // This depends on the actual structure of the API response
    // const potholes: Pothole[] = data.surfaces.map((item: any) => ({
    //   id: item.id?.toString() || Math.random().toString(36).substring(2, 11),
    //   latitude: item.latitude || item.lat,
    //   longitude: item.longitude || item.lng,
    //   severity: item.severity || 'medium'
    // }));
    
      // return potholes;
      return data.heatmap.surfaces
  } catch (error) {
    console.error('Failed to fetch pothole data:', error);
    
    // Fallback to mock data in case of error
    console.warn('Using mock data as fallback');
      return [
            { id: '1', longitude: -100.2, latitude: 40.1 },
            { id: '2', longitude: -100.3, latitude: 39.9 },
            { id: '3', longitude: -99.8, latitude: 40.2 },
            { id: '4', longitude: -100.1, latitude: 40.3 },
            { id: '5', longitude: -99.9, latitude: 39.8 },
          ] 
  }
}