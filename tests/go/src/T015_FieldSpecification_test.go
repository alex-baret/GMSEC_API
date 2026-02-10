//go:build gmsec_integration

package gotests

import (
	"testing"

	gmsec "gmsec"
)

func TestT015FieldSpecification(t *testing.T) {
	spec := gmsec.NewSpecification()
	mSpecs := spec.GetMessageSpecifications("2019.00", gmsec.MessageSpecifications_LEVEL_1)
	assertTrue(t, len(mSpecs) > 0, "message specs expected")

	fSpecs := mSpecs[0].GetFieldSpecifications()
	assertTrue(t, len(fSpecs) > 0, "field specs expected")

	f := fSpecs[0]
	assertTrue(t, f.GetName() != "", "field name expected")
	assertTrue(t, f.GetMode() != "", "field mode expected")
	_ = f.IsHeader()
}
