export interface SurfaceReading {
  id: string;
  longitude: number;
  latitude: number;
}

export interface Heatmap {
  idle: SurfaceReading[];
  asphalt: SurfaceReading[];
  gravel: SurfaceReading[];
  rough: SurfaceReading[];
  pothole: SurfaceReading[];
}