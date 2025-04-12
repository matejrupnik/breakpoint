export interface Pothole {
  id: string;
  latitude: number;
  longitude: number;
  severity?: 'low' | 'medium' | 'high';
}