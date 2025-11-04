const _graph = new WeakMap(); // source -> Set<{ target, update }>
const _parents = new WeakMap(); // target -> Set<source>
const _stats = new WeakMap(); // target -> { last_total_time, last_callb_time }

function _getSet(map, key) {
  let s = map.get(key);
  if (!s) {
    s = new Set();
    map.set(key, s);
  }
  return s;
}

export function addDependency(source, target, update) {
  if (!source || !target || typeof update !== "function") {
    throw new Error(
      "addDependency(source, target, update) requires non-null args and a function."
    );
  }

  const edge = { target, update };
  _getSet(_graph, source).add(edge);
  _getSet(_parents, target).add(source);

  if (!_stats.get(target)) {
    _stats.set(target, { last_total_time: 0, last_callb_time: 0 });
  }

  return function unsubscribe() {
    const set = _graph.get(source);
    if (set) set.delete(edge);
    const ps = _parents.get(target);
    if (ps) {
      ps.delete(source);
      if (!ps.size) _parents.delete(target);
    }
  };
}

export function removeDependency(source, target) {
  const set = _graph.get(source);
  if (!set) return;
  if (target === undefined) {
    for (const { target: t } of set) {
      const ps = _parents.get(t);
      if (ps) {
        ps.delete(source);
        if (!ps.size) _parents.delete(t);
      }
    }
    _graph.delete(source);
    return;
  }

  for (const edge of set) {
    if (edge.target === target) {
      set.delete(edge);
      const ps = _parents.get(target);
      if (ps) {
        ps.delete(source);
        if (!ps.size) _parents.delete(target);
      }
      break;
    }
  }
  if (!set.size) _graph.delete(source);
}

export function updateDependencies(source, options = {}) {
  const { beforeEach, afterEach } = options;
  if (!source) return;

  const q = [source];
  const visited = new Set([source]);

  while (q.length) {
    const s = q.shift();
    const deps = _graph.get(s);
    if (!deps) continue;

    for (const { target, update } of deps) {
      const t0 = performance.now();

      beforeEach && beforeEach(target, s);

      const c0 = performance.now();
      try {
        update(target, s);
      } catch (e) {
        console.error("dependency update error:", e);
      }
      const c1 = performance.now();

      afterEach && afterEach(target, s);

      const t1 = performance.now();

      const stat = _stats.get(target) || {
        last_total_time: 0,
        last_callb_time: 0,
      };
      stat.last_callb_time = c1 - c0;
      stat.last_total_time = t1 - t0;
      _stats.set(target, stat);

      if (!visited.has(target)) {
        visited.add(target);
        q.push(target);
      }
    }
  }
}

export function getDependencyStats(node) {
  return _stats.get(node) || { last_total_time: 0, last_callb_time: 0 };
}

export function hasParents(node) {
  const ps = _parents.get(node);
  return !!(ps && ps.size);
}

export function clearDependencies() {
  _graph.clear();
  _parents.clear();
  _stats.clear();
}
