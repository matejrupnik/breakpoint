export interface Pothole {
  id: string;
  longitude: number;
  latitude: number;
}

export interface Heatmap {
    surfaces: Pothole[];
}