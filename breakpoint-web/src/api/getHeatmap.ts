import { Heatmap } from './../types/pothole';
import axios from 'axios';

export async function getHeatmap(): Promise<Heatmap> {
  try {
    console.log('Fetching data from API with axios...');
    const response = await axios.get('http://165.232.115.82:4000/api/heatmap', {
      params: {
        longitude: 14.50,
        latitude: 46.05
      }
    });
    
      const data = response.data;
      
    return data.heatmap;
  } catch (error) {
    console.error('Failed to fetch pothole data:', error);
    
    console.warn('Using mock data as fallback');
    return {
      idle: [],
      asphalt: [],
      gravel: [],
      rough: [],
      pothole: []
    }; 
  }
}
