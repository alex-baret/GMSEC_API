# GMSEC Go unit-test scaffolds

This directory now contains Go test scaffolds for tests **T001-T016** and **T043**.

The files are gated behind `//go:build gmsec_integration` so they do not compile until
the generated GMSEC Go bindings are available in the test environment.

To run once bindings are installed and middleware is configured:

```bash
go test -tags gmsec_integration ./tests/go/src
```
