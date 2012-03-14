using Gee;

namespace Hasqap {

	public class Solver {
		private int n; 			// Problem size
		private int[,] A;			// Flow Matrix
		private int[,] B;			// Distance Matrix
		private int[,] C;			// Linear Term Matrix
		private double[,] trace;	// Ant pheromone traces
		public Permutation best;	// Best found permutation
		private Swaps swaps;		// Set of possible swaps on a permutation of size n (can be shuffled)
		private ArrayList<Permutation> ants = new ArrayList<Permutation> ();
		private bool intensification = false;
		private HashMap<int, int> fixations = new HashMap<int, int> (); // Fixed facility -> location mappings

		private int iterations;			// Number of iterations to be done
		public int m = 10;			// Number of ants
		public int R;				// Number of swaps done by pheromone trail modification
		public double q = 0.9;		// Probability of choosing exploiting in favor of exploring
		public double Q = 100;		// Pheromone intitialization parameter (tr0 = 1 / (Q * best_cost)
		public double alpha1 = 0.1;	// evaporation factor (0 = no evaporation, 1 = instant evaporation)
		public double alpha2 = 0.1;	// Pheromone update parameter (tr += alpha2 / best_cost)
		public int S;				// Number of non-improving iterations after which diversification is performed
		public bool abort_on_diversification = false;

		public Solver (int n, int[,] A, int[,] B, int[,] C, int iterations = 100) {
			this.n = n;
			this.A = A;
			this.B = B;
			this.C = C;
			this.iterations = iterations;
			trace = new double[n,n];

			// set n-dependent parameters
			R = (int) (this.n / 3);
			S = (int) (this.n / 2);

			this.swaps = new Swaps(this.n);

			this.init_ants();
		}
		/*
		 * Added functionality: Consider a facility fixed at a location
		 * but do incorporate flow information from/to this fixed
		 * facility when solving.
		 * (e.g. optimize a subset of keys in a keyboard layout)
		 */
		public void fixate (int facility, int location) {
			this.fixations.set(facility, location);

			var tmp = new ArrayList<Swap>();
			foreach (var swap in this.swaps) {
				if (swap.a == facility || swap.b == facility)
					tmp.add(swap);
			}

			foreach (var swap in tmp) {
				//stdout.printf("Remove Swap: %i to %i\n", swap.a, swap.b);
				this.swaps.remove(swap);
			}
			this.init_ants();
		}
		public void set_params (int m, int R, double q, double Q, double alpha1, double alpha2, int S, bool abort_on_diversification) {
			this.m = m;
			this.R = R;
			this.q = q;
			this.Q = Q;
			this.alpha1 = alpha1;
			this.alpha2 = alpha2;
			this.S = S;
			this.abort_on_diversification = abort_on_diversification;
			this.init_ants();
		}
		private void init_ants () {
			ants.clear();
			for (var k = 0; k < this.m; k++) {
				ants.insert(k, new Permutation.random (this.n));

				foreach(var fixation in this.fixations.entries) {
					ants[k].set(fixation.key, fixation.value);

				}
				ants[k].cost = compute_cost(ants[k]);
			}
			this.best = ants[0].clone();
		}

		private int weighted_choice (double[] weights, double sum) {
			double rand = Random.next_double() * sum;
			for (var i = 0; i < weights.length; i++) {
				rand -= weights[i];
				if (rand < 0)
					return i;
			}
			return 0;
		}
		private int cost_delta (Permutation pi, int i, int j) {
			int delta = (A[i, i] - A[j, j]) * (B[pi[j], pi[j]] - B[pi[i], pi[i]])
					+ (A[i, j] - A[j, i]) * (B[pi[j], pi[i]] - B[pi[i], pi[j]])
					+ C[i, pi[j]] - C[i, pi[i]] + C[j, pi[i]] - C[j, pi[j]];
			for (var k = 0; k < pi.size; k++) {
				if (k == i || k == j)
					continue;
				delta += (A[k, i] - A[k, j]) * (B[pi[k], pi[j]] - B[pi[k], pi[i]])
					+ (A[i, k] - A[j, k]) * (B[pi[j], pi[k]] - B[pi[i], pi[k]]);
			}
			return delta;
		}
		private void pheromone_init() {
			for (var i = 0; i < n; i++)
				for (var j = 0; j < n; j++)
					trace[i, j] = 1 / (Q * best.cost);
		}
		private void pheromone_update() {
			for (var i = 0; i < n; i++) {
				for (var j = 0; j < n; j++)
					trace[i, j] *= 1 - alpha1;
				trace[i, best[i]] += alpha2 / best.cost;
			}
		}
		private int compute_cost (Permutation p) {
			int cost = 0;
			for (var i = 0; i < n; i++) {
				for (var j = 0; j < n; j++)
					cost += A[i,j] * B[p[i],p[j]];
				cost += C[i,p[i]];
			}
			return cost;
		}
		private void local_search (Permutation p, int iterations = 2) {
			bool improvement;
			swaps.shuffle();
			for (var i = 0; i < iterations; i++) {
				improvement = false;
				foreach (var swap in swaps) {
					var delta = cost_delta(p, swap.a, swap.b);
					if (delta < 0) {
						p.swap(swap.a, swap.b);
						p.cost += delta;
						improvement = true;
					}
				}
				if (!improvement)
					break;
			}
		}
		private void pheromone_based_modification (Permutation p) {
			for (var i = 0; i < R; i++) {
				int r = Random.int_range(0, n);
				int s = 0;

				double[] r_pheromone = new double[n];
				double r_pheromone_sum = 0;
				double r_pheromone_max = 0;
				int r_best = s;
				for (var j = 0; j < n; j++) {
					r_pheromone[j] = trace[r, j] + trace[j, r];
					r_pheromone_sum += r_pheromone[j];
					if (r_pheromone[j] > r_pheromone_max)
						r_best = j;
				}

				if (q + Random.next_double() > 1) {
					s = r_best;
				} else {
					s = weighted_choice (r_pheromone, r_pheromone_sum);
				}

				if (this.fixations.has_key(r) || this.fixations.has_key(s)) {
					//i--;
					continue;
				}
				p.cost += cost_delta(p, r, s);
				p.swap(r, s);
			}
		}
		public void print_matrix (int[,] M) {
			int n = M.length[0];
			for (var i = 0; i < n; i++) {
				for (var j = 0; j < n; j++) {
					stdout.printf("%3d ", M[i,j]);
				}
				stdout.printf("\n");
			}
		}
		public void print_matrixd (double[,] M) {
			int n = M.length[0];
			for (var i = 0; i < n; i++) {
				for (var j = 0; j < n; j++) {
					stdout.printf("%3.0f ", M[i,j] * 1e11);
				}
				stdout.printf("\n");
			}
		}
		public void print_permutation(Permutation p) {
			for (var i = 0; i < p.size; i++) {
				stdout.printf("%3d ", p[i]);
			}
			stdout.printf(" (%d)\n", p.cost);
		}

		public void search (int? iterations = null) {
			if (iterations == null)
				iterations = this.iterations;

			// Apply local search
			for (var k = 0; k < m; k++) {
				local_search(ants[k], int.MAX);
				if (ants[k].cost < best.cost)
					best = ants[k].clone();
			}
			print_permutation(best);

			pheromone_init();

			int last_improvement = 0;
			for (var i = 0; i < iterations; i++) {
				var ant_improved = false;

				// Solution manipulation
				for (var k = 0; k < m; k++) {

					if (intensification) {
						var old = ants[k].clone();
						pheromone_based_modification(ants[k]);
						local_search(ants[k]);

						if (old.cost < ants[k].cost) {
							// no improvement -> go back to old solution
							ants[k] = old;
						} else {
							// keep modified solution
							ant_improved = true;
						}
					} else {
						pheromone_based_modification(ants[k]);
						local_search(ants[k]);
					}

					if (ants[k].cost < best.cost) {
						best = ants[k].clone();

						print_permutation(best);

						intensification = true;

						last_improvement = i;


					}
				}
				pheromone_update();


				if (i - last_improvement >= S) {
					// the best solution has not been improved for S iterations => Diversification
					if (abort_on_diversification)
						break;

					last_improvement = i;
					pheromone_init();

					ants[0] = best.clone();
					for (var k = 1; k < m; k++) {
						ants.set(k, new Permutation.random (n));
						foreach(var fixation in this.fixations.entries) {
							ants[k].set(fixation.key, fixation.value);
							//stdout.printf("fixing %i to %i\n", fixation.key, fixation.value);
						}
						ants[k].cost = compute_cost(ants[k]);
						local_search(ants[k], 1);
					}
					continue;
				}
				if (!ant_improved && intensification) {
					// no ant has improved => disable intensification
					intensification = false;
				}
			}
		}
	}

}
