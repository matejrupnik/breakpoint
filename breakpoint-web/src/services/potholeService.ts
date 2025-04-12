import { Pothole } from '../types/pothole';

// API endpoint for pothole data
const API_ENDPOINT = 'http://165.232.115.82:4000/api/heatmap';

// Mock data as fallback
const MOCK_POTHOLES: Pothole[] = [
  { id: '1', longitude: -100.2, latitude: 40.1 },
  { id: '2', longitude: -100.3, latitude: 39.9 },
  { id: '3', longitude: -99.8, latitude: 40.2 },
  { id: '4', longitude: -100.1, latitude: 40.3 },
  { id: '5', longitude: -99.9, latitude: 39.8 },
];

export async function getPotholes(): Promise<Pothole[]> {
  try {
    // Call the real API endpoint
    const response = await fetch(API_ENDPOINT);
    
    if (!response.ok) {
      throw new Error(`API error: ${response.status}`);
    }
    
    const data = await response.json();
    
    // Transform the API response to match our Pothole interface if needed
    // This depends on the actual structure of the API response
    const potholes: Pothole[] = data.map((item: any) => ({
      id: item.id?.toString() || Math.random().toString(36).substring(2, 11),
      latitude: item.latitude || item.lat,
      longitude: item.longitude || item.lng,
      severity: item.severity || 'medium'
    }));
    
    return potholes;
  } catch (error) {
    console.error('Failed to fetch pothole data:', error);
    
    // Fallback to mock data in case of error
    console.warn('Using mock data as fallback');
    return MOCK_POTHOLES;
  }
}

export async function getPotholeById(id: string): Promise<Pothole | undefined> {
  try {
    // Get all potholes and find the one with matching ID
    const potholes = await getPotholes();
    return potholes.find(p => p.id === id);
  } catch (error) {
    console.error('Failed to fetch specific pothole:', error);
    
    // Fallback to mock data
    return MOCK_POTHOLES.find(p => p.id === id);
  }
}