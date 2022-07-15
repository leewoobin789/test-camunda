// Code generated by github.com/actgardner/gogen-avro/v10. DO NOT EDIT.
/*
 * SOURCE:
 *     value-schema.avsc
 */
package avroschema

import (
	"encoding/json"
	"fmt"
	"io"

	"github.com/actgardner/gogen-avro/v10/compiler"
	"github.com/actgardner/gogen-avro/v10/vm"
	"github.com/actgardner/gogen-avro/v10/vm/types"
)

var _ = fmt.Printf

// value schema for incoming topic ex) order
type Order struct {
	Name string `json:"name"`

	FamilyName string `json:"familyName"`

	Birth int32 `json:"birth"`

	CustomId string `json:"customId"`

	UnitPrice float64 `json:"unitPrice"`

	Amount int32 `json:"amount"`

	Credit float64 `json:"credit"`

	Distance int32 `json:"distance"`
}

const OrderAvroCRC64Fingerprint = "OY\x8c\x02f\xba\xba\xfe"

func NewOrder() Order {
	r := Order{}
	r.UnitPrice = 0
	r.Amount = 0
	r.Credit = 0
	r.Distance = 0
	return r
}

func DeserializeOrder(r io.Reader) (Order, error) {
	t := NewOrder()
	deser, err := compiler.CompileSchemaBytes([]byte(t.Schema()), []byte(t.Schema()))
	if err != nil {
		return t, err
	}

	err = vm.Eval(r, deser, &t)
	return t, err
}

func DeserializeOrderFromSchema(r io.Reader, schema string) (Order, error) {
	t := NewOrder()

	deser, err := compiler.CompileSchemaBytes([]byte(schema), []byte(t.Schema()))
	if err != nil {
		return t, err
	}

	err = vm.Eval(r, deser, &t)
	return t, err
}

func writeOrder(r Order, w io.Writer) error {
	var err error
	err = vm.WriteString(r.Name, w)
	if err != nil {
		return err
	}
	err = vm.WriteString(r.FamilyName, w)
	if err != nil {
		return err
	}
	err = vm.WriteInt(r.Birth, w)
	if err != nil {
		return err
	}
	err = vm.WriteString(r.CustomId, w)
	if err != nil {
		return err
	}
	err = vm.WriteDouble(r.UnitPrice, w)
	if err != nil {
		return err
	}
	err = vm.WriteInt(r.Amount, w)
	if err != nil {
		return err
	}
	err = vm.WriteDouble(r.Credit, w)
	if err != nil {
		return err
	}
	err = vm.WriteInt(r.Distance, w)
	if err != nil {
		return err
	}
	return err
}

func (r Order) Serialize(w io.Writer) error {
	return writeOrder(r, w)
}

func (r Order) Schema() string {
	return "{\"doc\":\"value schema for incoming topic ex) order\",\"fields\":[{\"name\":\"name\",\"type\":\"string\"},{\"name\":\"familyName\",\"type\":\"string\"},{\"name\":\"birth\",\"type\":{\"logicalType\":\"date\",\"type\":\"int\"}},{\"name\":\"customId\",\"type\":\"string\"},{\"default\":0,\"name\":\"unitPrice\",\"type\":\"double\"},{\"default\":0,\"name\":\"amount\",\"type\":\"int\"},{\"default\":0,\"name\":\"credit\",\"type\":\"double\"},{\"default\":0,\"name\":\"distance\",\"type\":\"int\"}],\"name\":\"de.topic.in.Order\",\"type\":\"record\"}"
}

func (r Order) SchemaName() string {
	return "de.topic.in.Order"
}

func (_ Order) SetBoolean(v bool)    { panic("Unsupported operation") }
func (_ Order) SetInt(v int32)       { panic("Unsupported operation") }
func (_ Order) SetLong(v int64)      { panic("Unsupported operation") }
func (_ Order) SetFloat(v float32)   { panic("Unsupported operation") }
func (_ Order) SetDouble(v float64)  { panic("Unsupported operation") }
func (_ Order) SetBytes(v []byte)    { panic("Unsupported operation") }
func (_ Order) SetString(v string)   { panic("Unsupported operation") }
func (_ Order) SetUnionElem(v int64) { panic("Unsupported operation") }

func (r *Order) Get(i int) types.Field {
	switch i {
	case 0:
		w := types.String{Target: &r.Name}

		return w

	case 1:
		w := types.String{Target: &r.FamilyName}

		return w

	case 2:
		w := types.Int{Target: &r.Birth}

		return w

	case 3:
		w := types.String{Target: &r.CustomId}

		return w

	case 4:
		w := types.Double{Target: &r.UnitPrice}

		return w

	case 5:
		w := types.Int{Target: &r.Amount}

		return w

	case 6:
		w := types.Double{Target: &r.Credit}

		return w

	case 7:
		w := types.Int{Target: &r.Distance}

		return w

	}
	panic("Unknown field index")
}

func (r *Order) SetDefault(i int) {
	switch i {
	case 4:
		r.UnitPrice = 0
		return
	case 5:
		r.Amount = 0
		return
	case 6:
		r.Credit = 0
		return
	case 7:
		r.Distance = 0
		return
	}
	panic("Unknown field index")
}

func (r *Order) NullField(i int) {
	switch i {
	}
	panic("Not a nullable field index")
}

func (_ Order) AppendMap(key string) types.Field { panic("Unsupported operation") }
func (_ Order) AppendArray() types.Field         { panic("Unsupported operation") }
func (_ Order) HintSize(int)                     { panic("Unsupported operation") }
func (_ Order) Finalize()                        {}

func (_ Order) AvroCRC64Fingerprint() []byte {
	return []byte(OrderAvroCRC64Fingerprint)
}

func (r Order) MarshalJSON() ([]byte, error) {
	var err error
	output := make(map[string]json.RawMessage)
	output["name"], err = json.Marshal(r.Name)
	if err != nil {
		return nil, err
	}
	output["familyName"], err = json.Marshal(r.FamilyName)
	if err != nil {
		return nil, err
	}
	output["birth"], err = json.Marshal(r.Birth)
	if err != nil {
		return nil, err
	}
	output["customId"], err = json.Marshal(r.CustomId)
	if err != nil {
		return nil, err
	}
	output["unitPrice"], err = json.Marshal(r.UnitPrice)
	if err != nil {
		return nil, err
	}
	output["amount"], err = json.Marshal(r.Amount)
	if err != nil {
		return nil, err
	}
	output["credit"], err = json.Marshal(r.Credit)
	if err != nil {
		return nil, err
	}
	output["distance"], err = json.Marshal(r.Distance)
	if err != nil {
		return nil, err
	}
	return json.Marshal(output)
}

func (r *Order) UnmarshalJSON(data []byte) error {
	var fields map[string]json.RawMessage
	if err := json.Unmarshal(data, &fields); err != nil {
		return err
	}

	var val json.RawMessage
	val = func() json.RawMessage {
		if v, ok := fields["name"]; ok {
			return v
		}
		return nil
	}()

	if val != nil {
		if err := json.Unmarshal([]byte(val), &r.Name); err != nil {
			return err
		}
	} else {
		return fmt.Errorf("no value specified for name")
	}
	val = func() json.RawMessage {
		if v, ok := fields["familyName"]; ok {
			return v
		}
		return nil
	}()

	if val != nil {
		if err := json.Unmarshal([]byte(val), &r.FamilyName); err != nil {
			return err
		}
	} else {
		return fmt.Errorf("no value specified for familyName")
	}
	val = func() json.RawMessage {
		if v, ok := fields["birth"]; ok {
			return v
		}
		return nil
	}()

	if val != nil {
		if err := json.Unmarshal([]byte(val), &r.Birth); err != nil {
			return err
		}
	} else {
		return fmt.Errorf("no value specified for birth")
	}
	val = func() json.RawMessage {
		if v, ok := fields["customId"]; ok {
			return v
		}
		return nil
	}()

	if val != nil {
		if err := json.Unmarshal([]byte(val), &r.CustomId); err != nil {
			return err
		}
	} else {
		return fmt.Errorf("no value specified for customId")
	}
	val = func() json.RawMessage {
		if v, ok := fields["unitPrice"]; ok {
			return v
		}
		return nil
	}()

	if val != nil {
		if err := json.Unmarshal([]byte(val), &r.UnitPrice); err != nil {
			return err
		}
	} else {
		r.UnitPrice = 0
	}
	val = func() json.RawMessage {
		if v, ok := fields["amount"]; ok {
			return v
		}
		return nil
	}()

	if val != nil {
		if err := json.Unmarshal([]byte(val), &r.Amount); err != nil {
			return err
		}
	} else {
		r.Amount = 0
	}
	val = func() json.RawMessage {
		if v, ok := fields["credit"]; ok {
			return v
		}
		return nil
	}()

	if val != nil {
		if err := json.Unmarshal([]byte(val), &r.Credit); err != nil {
			return err
		}
	} else {
		r.Credit = 0
	}
	val = func() json.RawMessage {
		if v, ok := fields["distance"]; ok {
			return v
		}
		return nil
	}()

	if val != nil {
		if err := json.Unmarshal([]byte(val), &r.Distance); err != nil {
			return err
		}
	} else {
		r.Distance = 0
	}
	return nil
}
