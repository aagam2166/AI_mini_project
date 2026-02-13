import { optimizeSchedule } from "./api";
import { useState, useEffect } from "react";
import {
  BarChart,
  Bar,
  LineChart,
  Line,
  XAxis,
  YAxis,
  Tooltip,
  CartesianGrid,
  ResponsiveContainer,
} from "recharts";

function App() {
  const [form, setForm] = useState({
    name: "",
    power: "",
    duration: "",
    earliest: "",
    latest: "",
  });

  const [maxPar, setMaxPar] = useState("");

  const [appliances, setAppliances] = useState(() => {
    const saved = localStorage.getItem("appliances");
    return saved ? JSON.parse(saved) : [];
  });

  const [result, setResult] = useState(null);

  useEffect(() => {
    localStorage.setItem("appliances", JSON.stringify(appliances));
  }, [appliances]);

  const handleChange = (e) => {
    setForm({ ...form, [e.target.name]: e.target.value });
  };

  const addAppliance = () => {
    if (!form.name) return;

    setAppliances([
      ...appliances,
      {
        name: form.name,
        power: Number(form.power),
        duration: Number(form.duration),
        earliest: Number(form.earliest),
        latest: Number(form.latest),
      },
    ]);

    setForm({
      name: "",
      power: "",
      duration: "",
      earliest: "",
      latest: "",
    });
  };

  const handleOptimize = async () => {
    if (appliances.length === 0) return;

    const prices = [
      10,10,10,10,10,10,10,10,
      2,2,2,
      10,10,10,10,10,10,10,10,10,10,10,10,10
    ];

    const response = await optimizeSchedule({
      appliances,
      prices,
      max_par: maxPar ? Number(maxPar) : null,
    });

    console.log(response);
    setResult(response);
  };

  return (
    <div className="min-h-screen bg-gray-950 text-white">
      <header className="px-10 py-6 border-b border-gray-800">
        <h1 className="text-4xl font-bold">Smart Home Energy Management</h1>
      </header>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 p-10">
        {/* LEFT SIDE */}
        <div className="bg-gray-900 rounded-2xl p-6 border border-gray-800">
          <h2 className="text-2xl font-semibold mb-6">Add Appliance</h2>

          <div className="space-y-4">
            <input
              name="name"
              value={form.name}
              onChange={handleChange}
              placeholder="Appliance Name"
              className="w-full p-3 rounded-lg bg-gray-800 border border-gray-700"
            />
            <input
              name="power"
              value={form.power}
              onChange={handleChange}
              placeholder="Power (kW)"
              type="number"
              className="w-full p-3 rounded-lg bg-gray-800 border border-gray-700"
            />
            <input
              name="duration"
              value={form.duration}
              onChange={handleChange}
              placeholder="Duration (hours)"
              type="number"
              className="w-full p-3 rounded-lg bg-gray-800 border border-gray-700"
            />
            <input
              name="earliest"
              value={form.earliest}
              onChange={handleChange}
              placeholder="Earliest Start (0-23)"
              type="number"
              className="w-full p-3 rounded-lg bg-gray-800 border border-gray-700"
            />
            <input
              name="latest"
              value={form.latest}
              onChange={handleChange}
              placeholder="Latest End (1-24)"
              type="number"
              className="w-full p-3 rounded-lg bg-gray-800 border border-gray-700"
            />

            {/* MAX PAR INPUT */}
            <input
              value={maxPar}
              onChange={(e) => setMaxPar(e.target.value)}
              placeholder="Maximum Allowable PAR"
              type="number"
              step="0.1"
              className="w-full p-3 rounded-lg bg-gray-800 border border-gray-700"
            />

            <button
              onClick={addAppliance}
              className="w-full bg-blue-600 hover:bg-blue-700 p-3 rounded-lg font-semibold"
            >
              Add Appliance
            </button>
          </div>

          <div className="mt-8">
            <h3 className="text-lg font-semibold mb-3">Added Appliances</h3>

            {appliances.map((a, index) => (
              <div
                key={index}
                className="bg-gray-800 p-3 rounded-lg mb-2 text-sm flex justify-between"
              >
                <span>
                  {a.name} | {a.power}kW | {a.duration}h | {a.earliest}-{a.latest}
                </span>
                <button
                  onClick={() =>
                    setAppliances(appliances.filter((_, i) => i !== index))
                  }
                  className="text-red-400"
                >
                  Delete
                </button>
              </div>
            ))}

            {appliances.length > 0 && (
              <button
                onClick={handleOptimize}
                className="mt-4 w-full bg-green-600 hover:bg-green-700 p-3 rounded-lg font-semibold"
              >
                Optimize Schedule
              </button>
            )}
          </div>
        </div>

        {/* RIGHT SIDE */}
        <div className="bg-gray-900 rounded-2xl p-6 border border-gray-800">
          <h2 className="text-2xl font-semibold mb-6">Optimization Results</h2>

          {!result ? (
            <p className="text-gray-400">No optimization run yet.</p>
          ) : result.error ? (
            <p className="text-red-400">{result.error}</p>
          ) : (
            <>
              <div className="grid grid-cols-2 gap-4 mb-6">
                <div className="bg-gray-800 p-4 rounded-xl">
                  <p className="text-gray-400 text-sm">Total Cost</p>
                  <p className="text-2xl font-bold text-green-400">
                    ${result.optimized.cost.toFixed(2)}
                  </p>
                </div>
                <div className="bg-gray-800 p-4 rounded-xl">
                  <p className="text-gray-400 text-sm">Peak-to-Average Ratio</p>
                  <p className="text-2xl font-bold text-blue-400">
                    {result.optimized.par.toFixed(2)}
                  </p>
                </div>
              </div>

              {/* PRICE GRAPH */}
              <div className="mb-6">
                <p className="text-gray-400 mb-2">Electricity Price Profile</p>
                <div className="bg-gray-800 p-4 rounded-lg h-64">
                  <ResponsiveContainer width="100%" height="100%">
                    <LineChart
                      data={result.prices.map((price, hour) => ({ hour, price }))}
                    >
                      <CartesianGrid strokeDasharray="3 3" stroke="#374151" />
                      <XAxis dataKey="hour" stroke="#9ca3af" />
                      <YAxis stroke="#9ca3af" />
                      <Tooltip />
                      <Line
                        type="stepAfter"
                        dataKey="price"
                        stroke="#22c55e"
                        strokeWidth={2}
                        dot={false}
                      />
                    </LineChart>
                  </ResponsiveContainer>
                </div>
              </div>

              {/* LOAD GRAPH */}
              <div>
                <p className="text-gray-400 mb-2">Optimized Hourly Load</p>
                <div className="bg-gray-800 p-4 rounded-lg h-64">
                  <ResponsiveContainer width="100%" height="100%">
                    <BarChart
                      data={result.hourly_load.map((load, hour) => ({
                        hour,
                        load,
                      }))}
                    >
                      <CartesianGrid strokeDasharray="3 3" stroke="#374151" />
                      <XAxis dataKey="hour" stroke="#9ca3af" />
                      <YAxis stroke="#9ca3af" />
                      <Tooltip />
                      <Bar dataKey="load" fill="#3b82f6" />
                    </BarChart>
                  </ResponsiveContainer>
                </div>
              </div>
            </>
          )}
        </div>
      </div>
    </div>
  );
}

export default App;