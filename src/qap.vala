namespace Hasqap {
	public class OrderedSet<G> : Gee.ArrayList<G> {
		public void swap (int i, int j) {
			var tmp = this[i];
			this[i] = this[j];
			this[j] = tmp;
		}
		public void shuffle () {
			for (var i = 0; i < this.size - 1; i++) {
				this.swap(i, Random.int_range(i, this.size));
			}
		}
	}
	/*
	 * Represents a permutation. The swap-method is especially useful
	 * for applying transformations.
	 */
	public class Permutation : OrderedSet<int> {
		public int cost;
		public Permutation (int n) {
			Permutation.identity (n);
		}
		public Permutation.identity (int n) {
			for (var i = 0; i < n; i++)
				this.insert(i, i);
		}
		public Permutation.random (int n) {
			Permutation.identity (n);
			this.shuffle ();
		}
		public Permutation.unitialized () {
		}
		public new void set (int source, int target) {
			if (this[source] != target)
				this.swap(source, this.index_of(target));
		}
		public Permutation clone () {
			var clone = new Permutation.unitialized ();
			for (var i = 0; i < this.size; i++) {
				clone.insert(i, this[i]);
			}
			clone.cost = this.cost;
			return clone;
		}
	}
	/*
	 * Basically a tuple
	 */
	public class Swap {
		public int a;
		public int b;
		public Swap (int a, int b) {
			this.a = a;
			this.b = b;
		}
	}
	/*
	 * A list of swaps (tuples). Useful for tracking possible swaps on a
	 * permutation and shuffling them
	 */
	public class Swaps : OrderedSet<Swap> {
		public Swaps (int n) {
			for (var i = 0; i < n - 1; i++)
				for (var j = i + 1; j < n; j++)
					this.add(new Swap(i, j));
		}
	}
}
