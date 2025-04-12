import { Pothole } from '../types/pothole';

// Mock data for development
const MOCK_POTHOLES: Pothole[] = [
  { id: '1', longitude: -100.2, latitude: 40.1, severity: 'high' },
  { id: '2', longitude: -100.3, latitude: 39.9, severity: 'medium' },
  { id: '3', longitude: -99.8, latitude: 40.2, severity: 'low' },
  { id: '4', longitude: -100.1, latitude: 40.3, severity: 'high' },
  { id: '5', longitude: -99.9, latitude: 39.8, severity: 'medium' },
];

export async function getPotholes(): Promise<Pothole[]> {
  // For now return mock data
  // In production, this would be replaced with a real API call:
  // const response = await fetch('https://your-api-endpoint.com/potholes');
  // return response.json();
  
  return new Promise((resolve) => {
    // Simulate network delay
    setTimeout(() => resolve(MOCK_POTHOLES), 500);
  });
}

export async function getPotholeById(id: string): Promise<Pothole | undefined> {
  // For now use mock data
  // In production:
  // const response = await fetch(`https://your-api-endpoint.com/potholes/${id}`);
  // return response.json();
  
  return new Promise((resolve) => {
    setTimeout(() => {
      const pothole = MOCK_POTHOLES.find(p => p.id === id);
      resolve(pothole);
    }, 300);
  });
}