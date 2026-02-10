//go:build gmsec_integration

package gotests

import (
	"testing"

	gmsec "gmsec"
)

func TestT014MessageSpecification(t *testing.T) {
	spec := gmsec.NewSpecification()
	mSpecs := spec.GetMessageSpecifications("2019.00", gmsec.MessageSpecifications_LEVEL_1)
	assertTrue(t, len(mSpecs) > 0, "message specifications expected")

	first := mSpecs[0]
	assertTrue(t, first.GetSchemaID() != "", "schema id expected")
	assertTrue(t, first.GetTopic() != "", "topic expected")
	assertTrue(t, len(first.GetFieldSpecifications()) > 0, "field specifications expected")
}
