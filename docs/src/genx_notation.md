# Genx Notation

## Genx Indices and Sets
---
|**Notation** | **Description**|
| :------------ | :-----------|
|$t \in \mathcal{T}$ | where $t$ denotes an time step and $\mathcal{T}$ is the set of time steps over which grid operations are modeled|
$z \in \mathcal{Z}$ | where $z$ denotes a zone and $\mathcal{Z}$ is the set of zones in the network|
|$z \rightarrow z^{\prime} \in \mathcal{B}$ |where $z \rightarrow z^{\prime}$ denotes paths for different transport routes of electricity, hydrogen flow via pipelines and trucks, carbon flow via pipelines and trucks and $\mathcal{B}$ is the set of all possible routes|
|$s \in \mathcal{SEG}$||
|$z \in \mathcal{Z}^{CRM}_{p}$| each subset stands for a locational deliverability area (LDA) or a reserve sharing group|
|$\mathcal{Z}_{p,mass}^{CO_2}$|then the set will contain only one zone with no possibility of trading|
|$t \in \mathcal{T}^{start}$|This set of time-coupling constraints wrap around to ensure the power output in the first time step of each year (or each representative period), $t \in \mathcal{T}^{start}$|
---


## Decision Variables
---
|**Notation** | **Description**|
| :------------ | :-----------|
|$x_{k,z,t}^{E,THE} k \in \mathcal{K}, z\in \mathcal{Z}, t \in \mathcal{T}$| representing energy injected into the grid by thermal resource $k$ in zone $z$ at time period $t$|
|$x_{r,z,t}^{E,VRE} \forall r \in \mathcal{R}, z \in \mathcal{Z}, t \in \mathcal{T}$| representing energy injected into the grid by renewable resource $r$ in zone $z$ at time period $t$|
|$x_{s,z,t}^{E,DIS} \forall s \in \mathcal{S}, z t \in \mathcal{T}$| representing energy injected into the grid by storage resource $s$ in zone $z$ at time period $t$|
|$y_{k}^{E,THE}$|total available thermal generation capacity |
|$y_{r}^{E,VRE}$|total available renewable generation capacity|
|$y_{s}^{E,STO,DIS}$|total available storage discharge capacity |
|$y_{g}^{E,GEN}$|the sum of the existing capacity plus the newly invested capacity minus any retired capacity|
|$C^{E,GEN,c}$|investment costs of generation (fixed OM plus investment costs) from all generation resources $g \in \mathcal{G}$ (thermal, renewable, storage, DR, flexible demand resources and hydro)|
|$C^{E,EMI} $|cost of add the CO2 emissions by plants in each zone|
|$x_{s,z,t}^{E,NSD} \forall z \in \mathcal{Z}, \forall t \in \mathcal{T}$|the non-served energy/curtailed demand decision variable representing the total amount of demand curtailed in demand segment $s$ at time period $t$ in zone $z$|
|$n_{s}^{E,NSD}$|representing the marginal willingness to pay for electricity of this segment of demand|
|$D_{z, t}^{E}$ |Note that the current implementation assumes demand segments are an equal share of hourly load in all zones|
|$f_{y,t,z}$|$f_{y,t,z} \geq 0$ is the contribution of generation or storage resource $y \in Y$ in time $t \in T$ and zone $z \in Z$ to frequency regulation|
|$r_{y,t,z}$|$r_{y,t,z} \geq 0$ is the contribution of generation or storage resource $y \in Y$ in time $t \in T$ and zone $z \in Z$ to operating reserves up|
|$unmet\_rsv_{t}$|$unmet\_rsv_{t} \geq 0$ denotes any shortfall in provision of operating reserves during each time period $t \in T$|
|$C^{rsv}$|There is a penalty added to the objective function to penalize reserve shortfalls|
|$\mathcal{D}_{z,t}$| is the forecasted electricity demand in zone $z$ at time $t$ (before any demand flexibility)|
|$\rho^{max}_{y,z,t}$ |is the forecasted capacity factor for variable renewable resource $y \in VRE$ and zone $z$ in time step $t$|
|$\Delta^{\text{total}}_{y,z}$| is the total installed capacity of variable renewable resources $y \in VRE$ and zone $z$|
|$\alpha^{Contingency,Aux}_{y,z}$|$\alpha^{Contingency,Aux}_{y,z} \in [0,1]$ is a binary auxiliary variable that is forced by the second and third equations above to be 1 if the total installed capacity $\Delta^{\text{total}}_{y,z} > 0$ for any generator $y \in \mathcal{UC}$ and zone $z$, and can be 0 otherwise|
|$x_{l,t}^{E,NET}$|Power flows on each line $l$ into or out of a zone (defined by the network map $f^{E,map}(\cdot): l \rightarrow z$), are considered in the demand balance equation for each zone|
|$f^{E,loss}(\cdot)$|The losses function $f^{E,loss}(\cdot)$ will depend on the configuration used to model losses (see below)|
|$TransON_{l,t}^{E,NET+}$|$TransON_{l,t}^{E,NET+}$ is a continuous variable, representing the product of the binary variable $ON_{l,t}^{E,NET+}$ and the expression, $(y_{l}^{E,NET,existing} + y_{l}^{E,NET,new})$|
|$\mathcal{S}_{m,l,t}^{E,NET}$|we represent the absolute value of the line flow variable by the sum of positive stepwise flow variables $(\mathcal{S}_{m,l,t}^{E,NET+}, \mathcal{S}_{m,l,t}^{E,NET-})$, associated with each partition of line losses computed using the corresponding linear expressions |
|$n_{k,z,t}^{E,THE}$|the commitment state variable of generator cluster $k$ in zone $z$ at time $t$ ,$\forall k \in \mathcal{K}, z \in \mathcal{Z}, t \in \mathcal{T}$|
|$n_{k,z,t}^{E,UP}$|the number of startup decision variable of generator cluster $k$ in zone $z$ at time $t$ ,$\forall k \in \mathcal{K}, z \in \mathcal{Z}, t \in \mathcal{T}$|
|$n_{k,z,t}^{E,DN}$|the number of shutdown decision variable  of generator cluster $k$ in zone $z$ at time $t$ ,$\forall k \in \mathcal{K}, z \in \mathcal{Z}, t \in \mathcal{T}$|
|$C^{E,start}$|this is the total cost of start-ups across all generators subject to unit commitment ($k \in \mathcal{UC}, \mathcal{UC} \subseteq \mathcal{G}$) and all time periods $t$|
| $p \in \mathcal{P}_{mass}^{CO_2}$ |Input data for each constraint requires the $CO_2$ allowance budget for each model zone|
|$\epsilon_{z,p,mass}^{CO_2}$|to be provided in terms of million metric tonnes|
|$overline{\epsilon_{z,p,load}^{CO_2}}$| denotes the emission limit in terms on t$CO_2$/MWh|
|$\mathcal{Z}_{p}^{ESR}$|For each constraint $p \in \mathcal{P}^{ESR}$, we define a subset of zones $z \in \mathcal{Z}_{p}^{ESR} \subset \mathcal{Z}$ that are eligible for trading renewable/clean energy credits to meet the corresponding renewable/clean energy requirement.|
|$\epsilon_{g,z,p}^{MinCapReq}$| is the eligiblity of a generator of technology $g$ in zone $z$ of requirement $p$ and will be equal to $1$ for eligible generators and will be zero for ineligible resources|
|$y_{r,z}^{E,VRE,total}$|VRE resources are a function of each technology's time-dependent hourly capacity factor , in per unit terms, and the total available capacity ($y_{r,z}^{E,VRE,total}$).|
|$y_{r,z}^{E,VRE,new}$|variables related to installed capacity ($y_{r,z}^{E,VRE,new}$) for all resource bins for a particular VRE resource type $r$ and zone $z$|
|$y_{r,z}^{E,VRE,retired}$|retired capacity ($y_{r,z}^{E,VRE,retired}$) for all resource bins for a particular VRE resource type $r$ and zone $z$|
|$R_{f,z,t}^{E,FLEX}$|maximum deferrable demand as a fraction of available capacity in a particular time step $t$, $R_{f,z,t}^{E,FLEX}$|
|$\eta_{f,z}^{E,FLEX}$|the energy losses associated with shifting demand|
|$x_{f,z,t}^{E,FLEX}$|the amount of deferred demand remaining to be served depends on the amount in the previous time step minus the served demand during time step $t$ ($\Theta_{y,z,t}$) while accounting for energy losses associated with demand flexibility, plus the demand that has been deferred during the current time step ($\Pi_{y,z,t}$)|
|$Q_{o,z, n}$|models inventory of storage technology $o \in O$ in zone $z$ in each input period $n \in \mathcal{N}$|
|$\kappa^{down/up}_{y,z}$|the maximum ramp rates ($\kappa^{down}_{y,z}$ and $\kappa^{up}_{y,z}$ ) in per unit terms|
|$\upsilon^{reg/rsv}_{y,z}$|The amount of frequency regulation and operating reserves procured in each time step is bounded by the user-specified fraction ($\upsilon^{reg}_{y,z}$,$\upsilon^{rsv}_{y,z}$) of nameplate capacity for each reserve type|
|$U_{s,z,t}^{E,STO}$|This module defines the initial storage energy inventory level variable $U_{s,z,t}^{E,STO} \forall s \in \mathcal{S}, z \in \mathcal{Z}, t \in \mathcal{T_{p}^{start}}$, representing initial energy stored in the storage device $s$ in zone $z$ at all starting time period $t$ of modeled periods|
|$\Delta U_{s,z,m}^{E,STO}$|This module defines the change of storage energy inventory level during each representative period $\Delta U_{s,z,m}^{E,STO} \forall s \in \mathcal{S}, z \in \mathcal{Z}, m \in \mathcal{M}$, representing the change of storage energy inventory level of the storage device $s$ in zone $z$ during each representative period $m$|
|$U_{s,z,n}$|this variable models inventory of storage technology $s \in \mathcal{S}$ in zone $z$ in each input period $n \in \mathcal{N}$. |
|$U_{s,z,t}^{E,STO}$|This module defines the storage energy inventory level variable $U_{s,z,t}^{E,STO} \forall s \in \mathcal{S}, z \in \mathcal{Z}, t \in \mathcal{T}$, representing energy stored in the storage device $s$ in zone $z$ at time period $t$|
|$x_{s,z,t}^{E,CHA}$|This module defines the power charge decision variable $x_{s,z,t}^{E,CHA}$ \forall s \in \mathcal{S}, z \in \mathcal{Z}, t \in \mathcal{T}$, representing charged power into the storage device $s$ in zone $z$ at time period $t$|
|$f_{s,z,t}^{E,CHA/DIS}$|where is the contribution of storage resources to frequency regulation while charging or discharging|
|$r_{s,z,t}^{E,CHA/DIS}$|$r_{s,z,t}^{E,CHA/DIS}$ are created for storage resources, to denote the contribution of storage resources to  reserves while charging or discharging|
|$\frac{y_{k,z}^{E,THE}}{\Omega_{k,z}^{E,THE,size}}$||
|$n_{k,z,t}^{E,THE}$|designates the commitment state of generator cluster $k$ in zone $z$ at time $t$|
|$n_{k,z,t}^{E,UP}$|represents number of startup decisions|
|$n_{k,z,t}^{E,DN}$|represents number of shutdown decisions|
|$y_{k,z}^{E,THE}$| is the Thermal resources total installed capacity|
|$x_{k,z,t}^{E,THE}$|is the energy injected into the grid by technology $y$ in zone $z$ at time $t$|
|$\tau_{k,z}^{E,UP/DN}$|is the minimum up or down time for units in generating cluster $k$ in zone $z$|
||$f_{k,z,t}^{E,THE}$| is the frequency regulation contribution limited by the maximum regulation contribution $\upsilon^{reg}_{k,z}$|
|$r_{k,z,t}^{E,THE}$| is the reserves contribution limited by the maximum reserves contribution $\upsilon^{rsv}_{k,z}$|
## Parameters
---
|**Notation** | **Description**|
| :------------ | :-----------|
|G = inputs["G"]     | Number of resources (generators, storage, DR, and DERs)|
|T = inputs["T"]     | Number of time steps|
|Z = inputs["Z"]     | Number of zones|
|$c_{g}^{E,INV}$||
|$c_{g}^{E,FOM}$||
|$\epsilon^{load}_{reg}$ and $\epsilon^{vre}_{reg}$ |are parameters specifying the required frequency regulation as a fraction of forecasted demand and variable renewable generation|
|$\epsilon_{y,z,p}^{CRM}$|the available capacity is the net injection into the transmission network in time step $t$ derated by the derating factor, also stored in the parameter|
|$\epsilon_{g,z}^{CO_2}$|For every generator $g$, the parameter reflects the specific $CO_2$ emission intensity in t$CO_2$/MWh associated with its operation|
|$VREIndex_{r,z}$|Parameter $VREIndex_{r,z}$, is used to keep track of the first bin, where $VREIndex_{r,z}=1$ for the first bin and $VREIndex_{r,z}=0$ for the remaining bins|
|$\tau^{advance/delay}_{f,z}$|the maximum time this demand can be advanced and delayed, defined by parameters, $\tau^{advance}_{f,z}$ and $\tau^{delay}_{f,z}$, respectively|
|$\mu^{stor}_{y,z}$|referring to the ratio of energy capacity to discharge power capacity, is used to define the available reservoir storage capacity|
|$\overline{R_{s,z}^{E,ENE}}$|For storage resources where upper bound $\overline{R_{s,z}^{E,ENE}}$ is defined, then we impose constraints on maximum storage energy capacity|
|$\underline{R_{s,z}^{E,ENE}}$|For storage resources where lower bound $\underline{R_{s,z}^{E,ENE}}$ is defined, then we impose constraints on minimum storage energy capacity|
|$\Omega_{k,z}^{E,THE,size}$|is the thermal unit size|
|$\kappa_{k,z,t}^{E,UP/DN}$|is the maximum ramp-up or ramp-down rate as a percentage of installed capacity|
|$\underline{\rho_{k,z}^{E,THE}}$|is the minimum stable power output per unit of installed capacity|
|$\overline{\rho_{k,z,t}^{E,THE}}$|is the maximum available generation per unit of installed capacity|
|||
---
