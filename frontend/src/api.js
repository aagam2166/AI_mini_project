import axios from "axios";

const BASE_URL = "http://localhost:8000";

export const optimizeSchedule = async (data) => {
  const response = await axios.post(`${BASE_URL}/optimize`, data);
  return response.data;
};