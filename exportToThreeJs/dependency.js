class DependencySystem {
  constructor() {
    this._graph = new WeakMap();
    this._parents = new WeakMap();
    this._stats = new WeakMap();
  }

  _getSet(map, key) {
    let s = map.get(key);
    if (!s) {
      s = new Set();
      map.set(key, s);
    }
    return s;
  }

  addDependency(source, target, update) {
    if (!source || !target || typeof update !== "function") {
      throw new Error(
        "addDependency(source, target, update) requires non-null args and a function."
      );
    }

    const edge = { target, update };
    this._getSet(this._graph, source).add(edge);
    this._getSet(this._parents, target).add(source);

    if (!this._stats.get(target)) {
      this._stats.set(target, { last_total_time: 0, last_callb_time: 0 });
    }

    return () => {
      const set = this._graph.get(source);
      if (set) set.delete(edge);
      const ps = this._parents.get(target);
      if (ps) {
        ps.delete(source);
        if (!ps.size) this._parents.delete(target);
      }
    };
  }

  removeDependency(source, target) {
    const set = this._graph.get(source);
    if (!set) return;

    if (target === undefined) {
      for (const { target: t } of set) {
        const ps = this._parents.get(t);
        if (ps) {
          ps.delete(source);
          if (!ps.size) this._parents.delete(t);
        }
      }
      this._graph.delete(source);
      return;
    }

    for (const edge of set) {
      if (edge.target === target) {
        set.delete(edge);
        const ps = this._parents.get(target);
        if (ps) {
          ps.delete(source);
          if (!ps.size) this._parents.delete(target);
        }
        break;
      }
    }
    if (!set.size) this._graph.delete(source);
  }

  updateDependencies(source, options = {}) {
    const { beforeEach, afterEach } = options;
    if (!source) return;

    const q = [source];
    const visited = new Set([source]);

    while (q.length) {
      const s = q.shift();
      const deps = this._graph.get(s);
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

        const stat = this._stats.get(target) || {
          last_total_time: 0,
          last_callb_time: 0,
        };
        stat.last_callb_time = c1 - c0;
        stat.last_total_time = t1 - t0;
        this._stats.set(target, stat);

        if (!visited.has(target)) {
          visited.add(target);
          q.push(target);
        }
      }
    }
  }

  getDependencyStats(node) {
    return this._stats.get(node) || { last_total_time: 0, last_callb_time: 0 };
  }

  hasParents(node) {
    const ps = this._parents.get(node);
    return !!(ps && ps.size);
  }

  clearDependencies() {
    this._graph = new WeakMap();
    this._parents = new WeakMap();
    this._stats = new WeakMap();
  }
}

export const globalDependencySystem = new DependencySystem();

export function addDependency(source, target, update) {
  return globalDependencySystem.addDependency(source, target, update);
}

export function removeDependency(source, target) {
  return globalDependencySystem.removeDependency(source, target);
}

export function updateDependencies(source, options = {}) {
  return globalDependencySystem.updateDependencies(source, options);
}

export function getDependencyStats(node) {
  return globalDependencySystem.getDependencyStats(node);
}

export function hasParents(node) {
  return globalDependencySystem.hasParents(node);
}

export function clearDependencies() {
  return globalDependencySystem.clearDependencies();
}

export function createDependencySystem() {
  return new DependencySystem();
}

export { DependencySystem };
