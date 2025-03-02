// Copyright 2023 Ant Group Co., Ltd.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package common

import (
	"context"

	apiextensionsclientset "k8s.io/apiextensions-apiserver/pkg/client/clientset/clientset"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/tools/record"

	kusciaclientset "github.com/secretflow/kuscia/pkg/crd/clientset/versioned"
)

type ControllerConstruction struct {
	NewControler NewControllerFunc
	CheckCRD     CheckCRDExistsFunc
}

type NewControllerFunc func(ctx context.Context, kubeClient kubernetes.Interface, kusciaClient kusciaclientset.Interface, eventRecorder record.EventRecorder) IController
type CheckCRDExistsFunc func(ctx context.Context, extensionClient apiextensionsclientset.Interface) error

type IController interface {
	Run(int) error
	Stop()
	Name() string
}
