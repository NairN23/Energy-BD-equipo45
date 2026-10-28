# SISTEMA DE GESTIÓN DE VENTAS DE SUPLEMENTOS NUTRICIONALES - ENERGY
## ETAPA I: REQUERIMIENTOS Y DOMINIO DEL NEGOCIO

**Nombre del equipo:** Grupo 45

### Integrantes
* Aquino Anabela
* Figuerola Melina
* Mancedo Juan
* Mormina Daniela
* Nazer Nair

---

## ETAPA I: REQUERIMIENTOS Y DOMINIO DEL NEGOCIO

### 1.1 Introducción al Rubro
Energy es una empresa dedicada al comercio electrónico minorista, especializada en la venta de suplementos dietarios, vitaminas y productos de nutrición deportiva.

La empresa comercializa productos orientados al rendimiento físico, el bienestar y la salud, como complejos multivitamínicos, proteínas, aminoácidos y combos de entrenamiento.

En este tipo de negocio es importante contar con información clara y actualizada. Los clientes necesitan poder consultar los productos disponibles, sus características, precios y stock antes de realizar una compra.

Además, debido a los cambios frecuentes de precios, es necesario que el sistema mantenga un registro correcto de cada venta realizada. De esta forma, una compra conserva el precio y los datos que tenía al momento de realizarse, aunque posteriormente se modifiquen los precios o la información de los productos.

---

### 1.2 Alcance del Sistema
Con el objetivo de garantizar la consistencia, disponibilidad e integridad de los datos en cada etapa de las operaciones, el modelo de datos dará soporte a las siguientes áreas del negocio:

1. **Gestión de Usuarios y Seguridad:** Registro, autenticación y control de acceso basado en roles (clientes y administradores).
2. **Gestión de Catálogo:** Administración de categorías y productos (incluyendo control de visibilidad, productos destacados y soporte para combos o packs especiales).
3. **Gestión de Carrito de Compras:** Persistencia temporal de artículos seleccionados por el cliente antes de concretar la orden.
4. **Procesamiento de Pedidos y Ventas:** Generación de órdenes de compra, cálculo automático de importes, congelamiento histórico de precios unitarios e instantánea de datos de entrega.
5. **Control de Inventario (Stock):** Verificación y descuento automático de stock ante ventas confirmadas.
6. **Gestión de Pagos:** Soporte para pasarelas de pago automáticas (Mercado Pago) y transferencias bancarias manuales con verificación de comprobante.
7. **Canal de Contacto:** Registro y administración de mensajes y consultas enviadas por los usuarios.

#### Exclusiones del Alcance (Límites del Sistema):
1. No abarca facturación fiscal electrónica directa (integración con web services de ARCA/AFIP).
2. No incluye logística y ruteo de envíos en tiempo real (seguimiento GPS del transporte).
3. No contempla la gestión de compras a proveedores ni órdenes de reposición mayorista (el stock se actualiza a nivel de inventario administrativo).

---

## 2. Reglas de Negocio (RN)
A continuación se presentan de manera explícita las reglas que determinan el funcionamiento del sistema y sirven como base para el diseño de la base de datos:

### RN01: Registro e Identificación de Clientes y Usuarios
1. Todo usuario debe identificarse de forma única mediante una dirección de correo electrónico válida (`email`) y autenticarse utilizando una contraseña cifrada.
2. Cada usuario tiene asignado obligatoriamente un rol en el sistema (por ejemplo: Administrador o Cliente).
3. El sistema debe permitir el borrado lógico (*soft delete*) de las cuentas para mantener la integridad referencial del historial de pedidos y registrar el correo original al momento de la baja (`deleted_email_original`).

### RN02: Gestión y Control de Inventario (Stock)
* Cada producto posee una cantidad de existencias disponible (*stock*), la cual debe ser un valor entero no negativo ($stock \ge 0$).
* No se puede confirmar un pedido si la cantidad solicitada de un producto supera el stock disponible en ese momento.
* Al confirmarse un pedido, el sistema debe descontar de forma atómica la cantidad comprada del stock del producto.
* Si un producto no está marcado como activo, no podrá ser visualizado en el catálogo público ni añadido al carrito de compras.

### RN03: Inmutabilidad e Historial de Precios Unitarios en Ventas
* Al generar un pedido, el precio vigente del producto en la tabla de productos debe copiarse y almacenarse de manera definitiva como `precio_unitario` en la tabla `pedido_detalles`.
* Los cambios posteriores en el precio del producto, ya sean aumentos, reducciones o promociones, no deben modificar los precios unitarios ni los subtotales o totales de pedidos generados anteriormente.
* El subtotal de cada ítem se calcula como:
  $$\text{subtotal} = \text{cantidad} \times \text{precio\_unitario}$$
  y el total del pedido es la suma exacta de dichos subtotales.

### RN04: Métodos y Validación de Pagos
1. Todo pedido debe asociarse a un método de pago explícito (`metodo_pago`).
2. El sistema admite dos modalidades principales:
   1. **Pasarela de pago electrónica (Mercado Pago):** Requiere el registro del identificador de transacción provisto por la pasarela (`mp_payment_id`).
   2. **Transferencia bancaria / Pago manual:** Requiere el almacenamiento de la referencia o ruta al archivo del comprobante de transferencia cargado por el cliente (`comprobante`).
3. El pedido se crea inicialmente con estado *Pendiente* y solo puede pasar a estados posteriores (*Pagado*, *En preparación*, *Enviado*) una vez confirmada la acreditación del pago.

### RN05: Persistencia del Carrito vs. Confirmación del Pedido
1. El carrito de compras es personal y se mantiene asociado a cada usuario registrado (`carritos`), permitiendo agregar productos y cantidades durante la navegación.
2. Los ítems agregados al carrito no reservan stock. La disponibilidad y el descuento efectivo del stock se validan únicamente al confirmar el pedido y generar la orden formal (`pedidos`).
3. Una vez confirmada la compra, los productos correspondientes deben eliminarse del carrito del usuario.

### RN06: Estructuración y Clasificación del Catálogo
* Todo producto debe estar asociado obligatoriamente a una única categoría válida del catálogo (`categoria_id`).
* Una categoría puede marcarse como inactiva; en ese caso, los productos asociados dejan de mostrarse en el catálogo general.
* El sistema permite definir productos especiales como "combos" (`es_combo = 1`), los cuales pueden almacenar la composición o desglose de suplementos que integran dicho paquete (`productos_combo`).

### RN07: Trazabilidad e Historial de Datos de Entrega
* Un cliente puede tener guardadas una o más direcciones frecuentes en su libreta de direcciones (`direcciones`).
* No obstante, al efectuarse un pedido, los datos de destino (`cliente_nombre`, `cliente_telefono`, `cliente_email` y `direccion_entrega`) se deben duplicar y almacenar de forma estática en la cabecera del pedido (`pedidos`).
* De esta manera, los cambios posteriores en el perfil o en la libreta de direcciones del usuario no modifican la dirección utilizada para una compra realizada anteriormente.

### RN08: Atención y Mensajería de Contacto
* Los usuarios (o visitantes del sitio) pueden enviar mensajes de consulta a través del sistema indicando nombre, correo, teléfono, asunto y contenido.
* Si la consulta es realizada por un cliente autenticado, se vincula a su identificador de usuario (`user_id`).
* Cada mensaje cuenta con una marca de estado de lectura (`leido`) que debe ser administrada por los operadores con rol administrativo.




# SISTEMA DE GESTIÓN DE VENTAS DE SUPLEMENTOS NUTRICIONALES - ENERGY

## ETAPA I: REQUERIMIENTOS Y DOMINIO DEL NEGOCIO

**Nombre del equipo:** Grupo 45

### Integrantes

- Aquino Anabela
- Figuerola Melina
- Mancedo Juan
- Mormina Daniela
- Nazer Nair

---

## 1. Descripción del Caso y Dominio del Negocio

### 1.1 Introducción al Rubro

Energy es una empresa dedicada al comercio electrónico minorista, especializada en la venta de suplementos dietarios, vitaminas y productos de nutrición deportiva.

La empresa comercializa productos orientados al rendimiento físico, el bienestar y la salud, como complejos multivitamínicos, proteínas, aminoácidos y productos destinados al entrenamiento.

En este tipo de negocio es importante contar con información clara y actualizada. Los clientes necesitan poder consultar los productos disponibles, sus características, precios y stock antes de realizar una compra.

Además, debido a los cambios frecuentes de precios, es necesario que el sistema mantenga un registro correcto de cada venta realizada. De esta forma, una compra conserva el precio y los datos correspondientes al momento de realizarse, aunque posteriormente se modifiquen los precios o la información de los productos.

---

### 1.2 Alcance del Sistema

El alcance del sistema comprende la gestión operativa, persistencia y trazabilidad de las transacciones de la plataforma, cubriendo las siguientes áreas:

1. **Gestión de Usuarios y Accesos:** Registro de cuentas, autenticación mediante credenciales protegidas, asignación de tipos de usuario, control del estado activo de las cuentas y registro de múltiples números telefónicos asociados a un usuario.

2. **Gestión de Direcciones y Localización:** Registro de los domicilios de los usuarios mediante una estructura compuesta por dirección, ciudad y provincia. Cada dirección se encuentra asociada a una ciudad, y cada ciudad pertenece a una provincia.

3. **Gestión de Catálogo e Inventario:** Administración y clasificación de productos por categorías, control de visibilidad mediante estados activos, identificación de productos destacados y control de existencias físicas mediante el stock disponible.

4. **Gestión del Carrito de Compras:** Administración de un carrito personal asociado a cada usuario registrado, utilizado como referencia para el proceso de generación de pedidos.

5. **Procesamiento de Pedidos y Ventas:** Generación de pedidos, registro de sus productos mediante el detalle del pedido, almacenamiento de cantidades y precios unitarios, cálculo de subtotales y total de la operación, asociación con el carrito que da origen a la compra y selección de la dirección correspondiente para la entrega.

6. **Gestión y Acreditación de Pagos:** Registro de los pagos asociados a los pedidos, contemplando el método utilizado, comprobante de pago cuando corresponda, fecha de acreditación y estado de la operación.

7. **Canal de Consultas y Soporte:** Recepción y administración de mensajes enviados tanto por usuarios registrados como por visitantes no autenticados, incluyendo datos de contacto, contenido de la consulta, fecha de envío y estado de lectura.

#### Exclusiones del Alcance (Límites del Sistema)

- No contempla facturación electrónica con entes fiscales (ARCA/AFIP).
- No incluye logística con seguimiento satelital (GPS) en tiempo real.
- No abarca la gestión de compras a distribuidores ni órdenes de reposición mayorista.

---

## 2. Reglas de Negocio (RN)

A continuación se presentan las reglas que determinan el funcionamiento del sistema y sirven como base para el diseño de la base de datos.

### RN01: Identificación de Usuarios y Accesos

1. Toda persona que se registre como usuario debe identificarse mediante una dirección de correo electrónico válida y única, junto con una contraseña protegida.

2. Cada usuario debe estar asociado obligatoriamente a un tipo de usuario, como Cliente o Administrador, que permita determinar su perfil dentro del sistema.

3. Un usuario puede registrar uno o más números telefónicos de contacto, los cuales se almacenan de manera independiente y permanecen asociados a su cuenta.

4. El sistema debe contemplar la deshabilitación lógica de usuarios mediante el atributo `activo`, evitando el borrado físico de la cuenta para preservar la información y las relaciones históricas asociadas.

---

### RN02: Control y Validación de Inventario (Stock)

1. Cada producto debe disponer de una cantidad de stock, cuyo valor debe ser un número entero no negativo.

2. El sistema debe verificar la disponibilidad de unidades antes de confirmar una venta, impidiendo la operación cuando la cantidad requerida supere el stock disponible.

3. Al confirmarse un pedido, las cantidades comercializadas deben descontarse del stock disponible del producto.

4. Si un producto se encuentra inactivo, no debe mostrarse como disponible para la venta.

5. Si la categoría a la que pertenece un producto se encuentra inactiva, los productos pertenecientes a dicha categoría tampoco deben estar disponibles para su comercialización.

---

### RN03: Inmutabilidad e Historial de Precios Unitarios

1. Al generarse el detalle de un pedido, el sistema debe almacenar el precio vigente del producto como `precioUnitario`.

2. El precio unitario almacenado en el detalle del pedido debe conservarse de forma histórica. Por lo tanto, las modificaciones posteriores realizadas sobre el precio del producto no deben alterar los pedidos registrados anteriormente.

3. Cada detalle de pedido debe registrar la cantidad solicitada y el precio unitario correspondiente.

4. El subtotal de cada detalle debe calcularse de acuerdo con la siguiente expresión:

   $$\text{subtotal} = \text{cantidad} \times \text{precioUnitario}$$

5. El total del pedido debe corresponder a la suma de los subtotales de todos sus detalles.

---

### RN04: Métodos y Acreditación de Pagos

1. Todo pago debe estar asociado a un pedido existente.

2. Para cada pago se debe registrar el método de pago utilizado mediante `metodoPago`.

3. Cuando el medio de pago requiera un comprobante, el sistema debe permitir registrar la información correspondiente mediante `comprobantePago`.

4. El sistema debe registrar la fecha de acreditación del pago mediante `fecha_Acreditacion` cuando la operación haya sido acreditada.

5. Cada pago debe contar con un estado que permita determinar su situación dentro del proceso de acreditación.

6. Los cambios de estado relacionados con la preparación o continuidad de un pedido deben producirse una vez que el pago correspondiente haya sido validado y acreditado.

---

### RN05: Asociación entre Usuario, Carrito y Pedido

1. Cada carrito debe estar asociado a un usuario registrado.

2. El carrito funciona como referencia del proceso de compra previo a la generación del pedido.

3. Al formalizar una compra, el pedido generado debe quedar asociado al carrito que le dio origen mediante `id_carrito`, permitiendo mantener la trazabilidad entre ambas operaciones.

4. Los productos efectivamente adquiridos se registran en `Detalle_pedido`, donde se almacena el producto, la cantidad correspondiente, el precio unitario y el subtotal.

5. La disponibilidad y el descuento efectivo del stock deben validarse al momento de confirmar el pedido.

---

### RN06: Domicilios de Entrega y Jerarquía Territorial

1. Un usuario puede registrar una o más direcciones.

2. Cada dirección debe registrar los datos de calle, número y barrio, y debe estar asociada a una ciudad.

3. Cada ciudad debe registrar su nombre y código postal (`CP`) y debe pertenecer a una provincia.

4. Cada provincia debe identificarse mediante su nombre.

5. Al momento de generar un pedido, el usuario debe seleccionar una de sus direcciones registradas para efectuar la entrega.

6. El pedido debe quedar asociado a la dirección seleccionada mediante `id_direccion`.

7. La estructura territorial del sistema debe respetar la siguiente jerarquía:

   **Provincia → Ciudad → Dirección**

---

### RN07: Canal de Atención y Consultas

1. El sistema debe permitir la recepción de mensajes de consulta.

2. Cada mensaje debe registrar nombre, correo electrónico, teléfono, asunto, contenido y fecha de envío.

3. Cada mensaje debe disponer de un estado de lectura mediante el atributo `leido`, que permita llevar un control de las consultas atendidas por los administradores.

4. Si el mensaje es enviado por un usuario autenticado, debe vincularse a su cuenta mediante `id_usuario`.

5. La asociación del mensaje con un usuario es opcional. Si la consulta es realizada por un visitante no autenticado, `id_usuario` podrá permanecer sin valor.

---

## 3. Correspondencia de las Reglas de Negocio con el Modelo de Datos

Las reglas de negocio definidas se encuentran representadas en el modelo de datos mediante las siguientes entidades principales:

- `Usuario` y `Tipo_usuario`: administración de usuarios y sus tipos de acceso.
- `Telefono`: almacenamiento de uno o más números telefónicos correspondientes a cada usuario.
- `Producto` y `Categoria`: administración del catálogo, precios, stock, productos destacados y estados de disponibilidad.
- `Carrito`: identificación del carrito correspondiente a cada usuario.
- `Pedido` y `Detalle_pedido`: registro de ventas, productos adquiridos, cantidades, precios históricos, subtotales y totales.
- `Pago`: registro de métodos de pago, comprobantes, fechas de acreditación y estados.
- `Direccion`, `Ciudad` y `Provincia`: representación de los domicilios y de la jerarquía territorial utilizada para las entregas.
- `Mensaje`: administración de consultas realizadas por usuarios registrados o visitantes.

De esta manera, el modelo de datos mantiene correspondencia con los requerimientos y reglas de negocio definidos para el sistema Energy.