//go:build gmsec_integration

package gotests

import (
	"testing"

	gmsec "gmsec"
)

func TestT013SchemaIDIterator(t *testing.T) {
	spec := gmsec.NewSpecification()
	it := spec.GetSchemaIDIterator()

	count := 0
	for it.HasNext() {
		schemaID := it.Next()
		assertTrue(t, schemaID != "", "schema id should not be empty")
		count++
	}
	assertTrue(t, count > 0, "expected one or more schema ids")

	it.Reset()
	assertTrue(t, it.HasNext(), "iterator should have values after reset")
}
