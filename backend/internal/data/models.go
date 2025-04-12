package data

import (
	"database/sql"
	"errors"
)

var (
	ErrorRecordNotFound = errors.New("record not found")
	ErrorEditConflict   = errors.New("edit conflict")
)

type Models struct {
	//Layouts       LayoutModel
	//Users         UserModel
	//Tokens        TokenModel
	//Permissions   PermissionModel
	//Organizations OrganizationModel
}

func NewModels(db *sql.DB) Models {
	return Models{
		//Layouts:       LayoutModel{DB: db},
		//Users:         UserModel{DB: db},
		//Tokens:        TokenModel{DB: db},
		//Permissions:   PermissionModel{DB: db},
		//Organizations: OrganizationModel{DB: db},
	}
}
