// Row <-> API mappers. The Flutter app expects Mongo-style JSON: `_id`,
// camelCase keys, and ISO date strings. These translate Postgres snake_case
// rows to that contract (and inverse for inserts/updates), so the app stays
// unchanged. `undefined` values are dropped from insert/update payloads so we
// never overwrite columns the request didn't include.

const iso = (v) => (v == null ? v : new Date(v).toISOString());

const pruneUndefined = (obj) => {
  const out = {};
  for (const [k, v] of Object.entries(obj)) {
    if (v !== undefined) out[k] = v;
  }
  return out;
};

// ---- profile -------------------------------------------------------------
const profileToApi = (row) => {
  if (!row) return null;
  return {
    _id: row.id,
    name: row.name,
    username: row.username,
    email: row.email,
    unitPreference: row.unit_preference,
    dailyProteinGoal: row.daily_protein_goal,
    createdAt: iso(row.created_at),
    updatedAt: iso(row.updated_at)
  };
};

const profileUpdateToRow = (body) =>
  pruneUndefined({
    name: body.name,
    unit_preference: body.unitPreference,
    daily_protein_goal: body.dailyProteinGoal,
    updated_at: new Date().toISOString()
  });

// ---- lifting -------------------------------------------------------------
const liftingToApi = (row) => {
  if (!row) return null;
  return {
    _id: row.id,
    date: iso(row.date),
    sessionName: row.session_name,
    exercises: row.exercises || [],
    voiceTranscript: row.voice_transcript,
    notes: row.notes,
    createdAt: iso(row.created_at),
    updatedAt: iso(row.updated_at)
  };
};

const liftingToRow = (body) =>
  pruneUndefined({
    date: body.date ? new Date(body.date).toISOString() : undefined,
    session_name: body.sessionName,
    exercises: body.exercises,
    voice_transcript: body.voiceTranscript,
    notes: body.notes
  });

// ---- food ----------------------------------------------------------------
const foodToApi = (row) => {
  if (!row) return null;
  return {
    _id: row.id,
    date: iso(row.date),
    mealName: row.meal_name,
    calories: row.calories,
    protein: row.protein,
    carbs: row.carbs,
    fat: row.fat,
    proteinGoalMet: row.protein_goal_met,
    createdAt: iso(row.created_at),
    updatedAt: iso(row.updated_at)
  };
};

const foodToRow = (body) =>
  pruneUndefined({
    date: body.date ? new Date(body.date).toISOString() : undefined,
    meal_name: body.mealName,
    calories: body.calories,
    protein: body.protein,
    carbs: body.carbs,
    fat: body.fat
  });

// ---- cardio --------------------------------------------------------------
const cardioToApi = (row) => {
  if (!row) return null;
  return {
    _id: row.id,
    date: iso(row.date),
    type: row.type,
    durationMinutes: row.duration_minutes,
    distance: row.distance == null ? 0 : Number(row.distance),
    avgHeartRate: row.avg_heart_rate,
    notes: row.notes,
    createdAt: iso(row.created_at),
    updatedAt: iso(row.updated_at)
  };
};

const cardioToRow = (body) =>
  pruneUndefined({
    date: body.date ? new Date(body.date).toISOString() : undefined,
    type: body.type,
    duration_minutes: body.durationMinutes,
    distance: body.distance,
    avg_heart_rate: body.avgHeartRate,
    notes: body.notes
  });

// ---- body weight ---------------------------------------------------------
const bodyWeightToApi = (row) => {
  if (!row) return null;
  return {
    _id: row.id,
    date: iso(row.date),
    weight: row.weight == null ? 0 : Number(row.weight),
    unit: row.unit,
    createdAt: iso(row.created_at),
    updatedAt: iso(row.updated_at)
  };
};

const bodyWeightToRow = (body) =>
  pruneUndefined({
    date: body.date ? new Date(body.date).toISOString() : undefined,
    weight: body.weight,
    unit: body.unit
  });

// ---- tip -----------------------------------------------------------------
const tipToApi = (row) => {
  if (!row) return null;
  return {
    _id: row.id,
    weekStartDate: iso(row.week_start_date),
    tipText: row.tip_text,
    dataSnapshot: row.data_snapshot,
    createdAt: iso(row.created_at),
    updatedAt: iso(row.updated_at)
  };
};

module.exports = {
  profileToApi,
  profileUpdateToRow,
  liftingToApi,
  liftingToRow,
  foodToApi,
  foodToRow,
  cardioToApi,
  cardioToRow,
  bodyWeightToApi,
  bodyWeightToRow,
  tipToApi
};
