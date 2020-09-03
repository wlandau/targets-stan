data {
  int <lower = 1> n;
  vector[n] x;
  vector[n] y;
}
parameters {
  real alpha;
  real beta;
  real <lower = 0> sigma;
}
model {
  y ~ normal(alpha + x * beta, sigma);
  alpha ~ normal(0, 1);
  beta ~ normal(0, 1);
  sigma ~ cauchy(0, 1);
}
