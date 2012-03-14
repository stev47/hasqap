using Hasqap;

static void main (string[] args) {
	/*
	 * Read QAP from stdin
	 */

	int n;
	if (stdin.scanf("%d", out n) != 1)
		stderr.printf("error reading\n");
	var A = new int[n,n];
	var B = new int[n,n];
	var C = new int[n,n];

	int linterm = 0;

	for (var i = 0; i < n; i++)
		for (var j = 0; j < n; j++)
			if (stdin.scanf("%d", out A[i, j]) != 1)
				stderr.printf("error reading\n");
	for (var i = 0; i < n; i++)
		for (var j = 0; j < n; j++)
			if (stdin.scanf("%d", out B[i, j]) != 1)
				stderr.printf("error reading\n");
	for (var i = 0; i < n; i++)
		for (var j = 0; j < n; j++)
			linterm = stdin.scanf("%d", out C[i, j]);

	if (linterm == 1)
		stdout.printf("Linear term supplied …\n");

	var solver = new Solver(n, A, B, C);

	int? iterations = null;
	if (args.length >= 2)
		iterations = int.parse(args[1]);

	solver.search(iterations);

}
