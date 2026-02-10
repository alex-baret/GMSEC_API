//go:build gmsec_integration

package gotests

import (
	"testing"

	gmsec "gmsec"
)

func TestT012Specification(t *testing.T) {
	spec := gmsec.NewSpecification()
	it := spec.GetSchemaIDIterator()
	assertTrue(t, it.HasNext(), "schema id iterator should not be empty")

	ids := 0
	for it.HasNext() {
		_ = it.Next()
		ids++
	}
	assertTrue(t, ids > 0, "expected at least one schema id")

	headers := spec.GetHeaderFieldNames("2019.00", gmsec.MessageSpecifications_LEVEL_1)
	assertTrue(t, len(headers) > 0, "expected header fields")
}
